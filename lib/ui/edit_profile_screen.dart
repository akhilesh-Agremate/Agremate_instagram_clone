import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as Im;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:path_provider/path_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final String? photoUrl, email, bio, name, phone;

  const EditProfileScreen({
    Key? key,
    this.photoUrl,
    this.email,
    this.bio,
    this.name,
    this.phone,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _repository = Repository();                                        // var → final
  User? currentUser;                                                        // FirebaseUser → User?
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();                                // Updated ImagePicker
  File? imageFile;                                                          // Added ?

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name ?? '';                              // Null safety
    _bioController.text = widget.bio ?? '';
    _emailController.text = widget.email ?? '';
    _phoneController.text = widget.phone ?? '';
    _repository.getCurrentUser().then((user) {
      if (user == null) return;                                            // Null guard
      setState(() {
        currentUser = user;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();                                             // Added disposes
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<File?> _pickImage(String action) async {                         // Return File?
    final XFile? pickedFile = await (action == 'Gallery'                  // Updated ImagePicker API
        ? _picker.pickImage(source: ImageSource.gallery)
        : _picker.pickImage(source: ImageSource.camera));

    if (pickedFile == null) return null;                                   // Null guard
    return File(pickedFile.path);                                          // XFile → File
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff8faf8),                         // Added const
        elevation: 1,
        title: const Text('Edit Profile'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, color: Colors.black),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              if (currentUser == null) return;                             // Null guard
              _repository
                  .updateDetails(
                currentUser!.uid,                                      // Added !
                _nameController.text,
                _bioController.text,
                _emailController.text,
                _phoneController.text,
              )
                  .then((v) => Navigator.pop(context));
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.done, color: Colors.blue),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              GestureDetector(
                onTap: _showImageDialog,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    width: 110.0,
                    height: 110.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80.0),
                      image: DecorationImage(
                        image: (widget.photoUrl == null ||
                            widget.photoUrl!.isEmpty)
                            ? const AssetImage('assets/no_image.png')
                        as ImageProvider                           // Cast for type compat
                            : NetworkImage(widget.photoUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showImageDialog,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    'Change Photo',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    labelText: 'Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 8.0),
                child: TextField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Bio',
                    labelText: 'Bio',
                  ),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text(
                  'Private Information',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 8.0),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email address',
                    labelText: 'Email address',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 8.0),
                child: TextField(
                  controller: _phoneController,                            // Added missing controller
                  decoration: const InputDecoration(
                    hintText: 'Phone Number',
                    labelText: 'Phone Number',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImageDialog() {                                                // Added void return type
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () async {
                final selectedImage = await _pickImage('Gallery');
                if (selectedImage == null) return;                         // Null guard
                setState(() => imageFile = selectedImage);
                await compressImage();                                     // Added await
                final url =
                await _repository.uploadImageToStorage(imageFile!);
                await _repository.updatePhoto(url, currentUser!.uid);
                if (mounted) Navigator.pop(context);                       // mounted check
              },
              child: const Text('Choose from Gallery'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                final selectedImage = await _pickImage('Camera');
                if (selectedImage == null) return;
                setState(() => imageFile = selectedImage);
                await compressImage();
                final url =
                await _repository.uploadImageToStorage(imageFile!);
                await _repository.updatePhoto(url, currentUser!.uid);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Take Photo'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> compressImage() async {                                     // Future<void>
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    final bytes = await imageFile!.readAsBytes();                         // Async read
    Im.Image? image = Im.decodeImage(bytes);                              // Added ?
    if (image == null) return;                                             // Null guard

    Im.Image resized = Im.copyResize(image, width: 500);                  // Named param 'width'

    final newFile = File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(resized, quality: 85));

    setState(() => imageFile = newFile);
    print('done');
  }
}