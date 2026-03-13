import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as Im;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/message.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:path_provider/path_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final String? photoUrl;
  final String? name;
  final String? receiverUid;

  const ChatDetailScreen({
    Key? key,
    this.photoUrl,
    this.name,
    this.receiverUid,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _senderuid;
  final TextEditingController _messageController = TextEditingController();
  final _repository = Repository();
  String? receiverPhotoUrl, senderPhotoUrl, receiverName, senderName;
  StreamSubscription<DocumentSnapshot>? subscription;   // Added ?
  File? imageFile;                                       // Added ?
  final ImagePicker _picker = ImagePicker();             // Updated ImagePicker

  @override
  void initState() {
    super.initState();
    print("RCID : ${widget.receiverUid}");
    _repository.getCurrentUser().then((user) {
      if (user == null) return;                          // Null guard
      setState(() {
        _senderuid = user.uid;
      });
      _repository.fetchUserDetailsById(_senderuid!).then((u) {
        setState(() {
          senderPhotoUrl = u.photoUrl;
          senderName = u.displayName;
        });
      });
      _repository.fetchUserDetailsById(widget.receiverUid!).then((u) {
        setState(() {
          receiverPhotoUrl = u.photoUrl;
          receiverName = u.displayName;
        });
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    _messageController.dispose();                        // Added dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xfff8faf8),       // Added const
        elevation: 1,
        title: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(widget.photoUrl ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(widget.name ?? ''),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: _senderuid == null
            ? const Center(child: CircularProgressIndicator()) // Centered
            : Column(
          children: <Widget>[
            chatMessagesListWidget(),                // Renamed to lowerCamelCase
            chatInputWidget(),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget chatInputWidget() {
    return Container(
      height: 55.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        validator: (String? input) {                     // Added ?
          if (input == null || input.isEmpty) {
            return "Please enter message";
          }
          return null;                                   // Added return null
        },
        controller: _messageController,
        decoration: InputDecoration(
          hintText: "Enter message...",
          labelText: "Message",
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.gradient),
                  color: Colors.black,
                  onPressed: () => pickImage(source: 'Gallery'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) { // Added !
                      sendMessage();
                    }
                  },
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          prefixIcon: IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => pickImage(source: 'Camera'),
            color: Colors.black,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
        ),
        onFieldSubmitted: (value) {
          _messageController.text = value;
        },
      ),
    );
  }

  Future<void> pickImage({String? source}) async {
    final XFile? pickedFile = await _picker.pickImage( // Updated ImagePicker API
      source: source == 'Gallery' ? ImageSource.gallery : ImageSource.camera,
    );

    if (pickedFile == null) return;                    // Null guard

    setState(() {
      imageFile = File(pickedFile.path);              // XFile → File
    });

    await compressImage();                            // Added await

    final url = await _repository.uploadImageToStorage(imageFile!);
    print("URL: $url");
    _repository.uploadImageMsgToDb(url, widget.receiverUid!, _senderuid!);
  }

  Future<void> compressImage() async {               // Changed to Future<void>
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    final bytes = await imageFile!.readAsBytes();    // Use async readAsBytes
    Im.Image? image = Im.decodeImage(bytes);         // Added ?

    if (image == null) return;                       // Null guard

    Im.Image resized = Im.copyResize(image, width: 500); // Named param 'width'

    var newFile = File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(resized, quality: 85));

    setState(() {
      imageFile = newFile;
    });
    print('done');
  }

  void sendMessage() {
    print("Inside send message");
    var text = _messageController.text;
    Message _message = Message(
      receiverUid: widget.receiverUid,
      senderUid: _senderuid,
      message: text,
      timestamp: Timestamp.now(),                    // FieldValue → Timestamp.now()
      type: 'text',
    );
    _repository.addMessageToDb(_message, widget.receiverUid!).then((v) {
      _messageController.text = "";
      print("Message added to db");
    });
  }

  Widget chatMessagesListWidget() {                  // Renamed: UpperCase → lowerCamelCase
    print("SENDERUID : $_senderuid");
    return Flexible(
      child: StreamBuilder<QuerySnapshot>(           // Added type
        stream: FirebaseFirestore.instance           // Firestore → FirebaseFirestore
            .collection('messages')
            .doc(_senderuid)                         // .document() → .doc()
            .collection(widget.receiverUid!)
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemBuilder: (context, index) =>
                chatMessageItem(snapshot.data!.docs[index]), // .documents → .docs
            itemCount: snapshot.data!.docs.length,
          );
        },
      ),
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: snapshot['senderUid'] == _senderuid
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: <Widget>[
              snapshot['senderUid'] == _senderuid
                  ? senderLayout(snapshot)
                  : receiverLayout(snapshot)
            ],
          ),
        )
      ],
    );
  }

  Widget senderLayout(DocumentSnapshot snapshot) {
    return snapshot['type'] == 'text'
        ? Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(22.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          snapshot['message'],
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        ),
      ),
    )
        : FadeInImage(
      fit: BoxFit.cover,
      image: NetworkImage(snapshot['photoUrl']),
      placeholder: const AssetImage('assets/blankimage.png'),
      width: 250.0,
      height: 300.0,
    );
  }

  Widget receiverLayout(DocumentSnapshot snapshot) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: snapshot['type'] == 'text'
            ? Text(
          snapshot['message'],
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        )
            : FadeInImage(
          fit: BoxFit.cover,
          image: NetworkImage(snapshot['photoUrl']),
          placeholder: const AssetImage('assets/blankimage.png'),
          width: 200.0,
          height: 200.0,
        ),
      ),
    );
  }
}