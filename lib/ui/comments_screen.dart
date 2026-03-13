import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/user.dart' as model;

class CommentsScreen extends StatefulWidget {
  final DocumentReference? documentReference;
  final model.User? user;

  const CommentsScreen({
    Key? key,
    this.documentReference,
    this.user,
  }) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController(); // Added final
  final _formKey = GlobalKey<FormState>();                                  // Added final

  @override
  void dispose() {
    _commentController.dispose();                                           // Moved before super
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: const Color(0xfff8faf8),                          // Added const
        title: const Text('Comments'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            commentsListWidget(),
            const Divider(height: 20.0, color: Colors.grey),               // Added const
            commentInputWidget(),
          ],
        ),
      ),
    );
  }

  Widget commentInputWidget() {
    return Container(
      height: 55.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.0,
            height: 40.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.0),
              image: DecorationImage(
                image: NetworkImage(widget.user?.photoUrl ?? ''),           // Null safety
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextFormField(
                validator: (String? input) {                                // Added ?
                  if (input == null || input.isEmpty) {
                    return "Please enter comment";
                  }
                  return null;                                              // Added return null
                },
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: "Add a comment...",
                ),
                onFieldSubmitted: (value) {
                  _commentController.text = value;
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_formKey.currentState!.validate()) {                     // Added !
                postComment();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: const Text(
                'Post',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void postComment() {                                                      // Added return type
    var _comment = Comment(
      comment: _commentController.text,
      timeStamp: Timestamp.now(),                                          // FieldValue → Timestamp.now()
      ownerName: widget.user?.displayName,
      ownerPhotoUrl: widget.user?.photoUrl,
      ownerUid: widget.user?.uid,
    );
    widget.documentReference!
        .collection("comments")
        .doc()                                                             // .document() → .doc()
        .set(_comment.toMap(_comment))                                     // .setData() → .set()
        .whenComplete(() {
      _commentController.text = "";
    });
  }

  Widget commentsListWidget() {
    print("Document Ref : ${widget.documentReference?.path}");
    return Flexible(
      child: StreamBuilder<QuerySnapshot>(                                 // Added type
        stream: widget.documentReference!
            .collection("comments")
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,                        // .documents → .docs
            itemBuilder: (context, index) =>
                commentItem(snapshot.data!.docs[index]),
          );
        },
      ),
    );
  }

  Widget commentItem(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;                 // .data → .data()

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data['ownerPhotoUrl'] ?? ''), // Null safety
              radius: 20,
            ),
          ),
          const SizedBox(width: 15.0),
          Row(
            children: <Widget>[
              Text(
                data['ownerName'] ?? '',                                  // Null safety
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(data['comment'] ?? ''),                       // Null safety
              ),
            ],
          ),
        ],
      ),
    );
  }
}