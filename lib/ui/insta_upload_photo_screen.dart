import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Im;
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:location/location.dart' as loc;                      // Alias added
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';

class InstaUploadPhotoScreen extends StatefulWidget {
  final File? imageFile;

  const InstaUploadPhotoScreen({Key? key, this.imageFile}) : super(key: key);

  @override
  _InstaUploadPhotoScreenState createState() => _InstaUploadPhotoScreenState();
}

class _InstaUploadPhotoScreenState extends State<InstaUploadPhotoScreen> {
  late TextEditingController _locationController;
  late TextEditingController _captionController;
  final _repository = Repository();
  bool _visibility = true;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
    _captionController = TextEditingController();
    _imageFile = widget.imageFile;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _changeVisibility(bool visibility) {
    setState(() => _visibility = visibility);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        backgroundColor: const Color(0xfff8faf8),
        elevation: 1.0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 20.0),
            child: GestureDetector(
              onTap: () async {
                _changeVisibility(false);
                final currentUser = await _repository.getCurrentUser();
                if (currentUser == null) {
                  print("Current User is null");
                  return;
                }
                await compressImage();
                final user =
                await _repository.retrieveUserDetails(currentUser);
                final url =
                await _repository.uploadImageToStorage(_imageFile!);
                await _repository
                    .addPostToDb(
                  user,
                  url,
                  _captionController.text,
                  _locationController.text,
                )
                    .catchError(
                        (e) => print("Error adding post to db: $e"));
                print("Post added to db");
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InstaHomeScreen(),
                  ),
                );
              },
              child: const Text(
                'Share',
                style: TextStyle(color: Colors.blue, fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(_imageFile!),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.only(left: 12.0, right: 8.0),
                  child: TextField(
                    controller: _captionController,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Add location',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: FutureBuilder<List<Placemark>>(
              future: locateUser(),
              builder: (context,
                  AsyncSnapshot<List<Placemark>> snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final place = snapshot.data!.first;
                  return Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _locationController.text =
                                place.locality ?? '';
                          });
                        },
                        child: Chip(
                          label: Text(place.locality ?? ''),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _locationController.text =
                              '${place.subAdministrativeArea ?? ''}, ${place.subLocality ?? ''}';
                            });
                          },
                          child: Chip(
                            label: Text(
                              '${place.subAdministrativeArea ?? ''}, ${place.subLocality ?? ''}',
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                print(
                    "Connection State : ${snapshot.connectionState}");
                return const CircularProgressIndicator();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Offstage(
              offstage: _visibility,
              child: const CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final rand = Random().nextInt(10000);

    final bytes = await _imageFile!.readAsBytes();
    Im.Image? image = Im.decodeImage(bytes);
    if (image == null) return;

    final resized = Im.copyResize(image, width: 500);

    final newFile = File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(resized, quality: 85));

    setState(() => _imageFile = newFile);
    print('done');
  }

  Future<List<Placemark>> locateUser() async {
    final location = loc.Location();                                  // Used alias

    try {
      final currentLocation = await location.getLocation();
      print(
          'LATITUDE : ${currentLocation.latitude} && LONGITUDE : ${currentLocation.longitude}');

      final placemarks = await placemarkFromCoordinates(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );
      return placemarks;
    } on PlatformException catch (e) {
      print('ERROR : $e');
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
      return [];
    }
  }
}
