import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/ui/insta_upload_photo_screen.dart';

class InstaAddScreen extends StatefulWidget {
  const InstaAddScreen({Key? key}) : super(key: key);

  @override
  _InstaAddScreenState createState() => _InstaAddScreenState();
}

class _InstaAddScreenState extends State<InstaAddScreen> {
  File? imageFile;                                                          // Added ?
  final ImagePicker _picker = ImagePicker();                                // Updated ImagePicker

  Future<File?> _pickImage(String action) async {                          // Return File?
    final XFile? pickedFile = await (action == 'Gallery'                   // Updated API
        ? _picker.pickImage(source: ImageSource.gallery)
        : _picker.pickImage(source: ImageSource.camera));

    if (pickedFile == null) return null;                                    // Null guard
    return File(pickedFile.path);                                           // XFile → File
  }

  void _showImageDialog() {                                                 // Added void
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () async {
                final selectedImage = await _pickImage('Gallery');
                if (selectedImage == null) return;                          // Null guard
                setState(() => imageFile = selectedImage);
                if (!mounted) return;                                       // mounted check
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InstaUploadPhotoScreen(imageFile: imageFile),
                  ),
                );
              },
              child: const Text('Choose from Gallery'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                final selectedImage = await _pickImage('Camera');
                if (selectedImage == null) return;
                setState(() => imageFile = selectedImage);
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InstaUploadPhotoScreen(imageFile: imageFile),
                  ),
                );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Add Photo'),                                     // Added const
      ),
      body: Center(
        child: ElevatedButton.icon(                                         // RaisedButton → ElevatedButton
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,                                  // color → backgroundColor
            splashFactory: InkSplash.splashFactory,
            shape: const StadiumBorder(),
          ),
          label: const Text(
            'Upload Image',
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(
            Icons.cloud_upload,
            color: Colors.white,
          ),
          onPressed: _showImageDialog,
        ),
      ),
    );
  }
}