import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_friend_profile_screen.dart';
import 'package:instagram_clone/ui/insta_profile_screen.dart';

class LikesScreen extends StatefulWidget {
  final DocumentReference? documentReference;
  final model.User? user;

  const LikesScreen({
    Key? key,
    this.documentReference,
    this.user,
  }) : super(key: key);

  @override
  _LikesScreenState createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  final _repository = Repository();                                     // var → final

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: const Color(0xfff8faf8),                      // Added const
        title: const Text('Likes'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(                     // Added type
        future: _repository.fetchPostLikes(widget.documentReference!),
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,                        // Added !
              itemBuilder: (context, index) {
                final data = snapshot.data![index].data()
                as Map<String, dynamic>;                           // .data → .data()
                final ownerName = data['ownerName'] as String? ?? '';
                final ownerPhotoUrl =
                    data['ownerPhotoUrl'] as String? ?? '';

                final isCurrentUser =
                    ownerName == widget.user?.displayName;             // Extracted for reuse

                void navigateToProfile() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => isCurrentUser
                          ? const InstaProfileScreen()
                          : InstaFriendProfileScreen(name: ownerName),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(left: 4.0, top: 16.0),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: navigateToProfile,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(ownerPhotoUrl),
                        radius: 30.0,
                      ),
                    ),
                    title: GestureDetector(
                      onTap: navigateToProfile,
                      child: Text(
                        ownerName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('No Likes found'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}