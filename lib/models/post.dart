import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? currentUserUid;
  String? imgUrl;
  String? caption;
  String? location;
  Timestamp? time; // Changed from FieldValue → Timestamp
  String? postOwnerName;
  String? postOwnerPhotoUrl;

  Post({
    this.currentUserUid,
    this.imgUrl,
    this.caption,
    this.location,
    this.time,
    this.postOwnerName,
    this.postOwnerPhotoUrl,
  });

  Map<String, dynamic> toMap(Post post) {
    return {
      'ownerUid': post.currentUserUid,
      'imgUrl': post.imgUrl,
      'caption': post.caption,
      'location': post.location,
      'time': FieldValue.serverTimestamp(), // FieldValue only when writing
      'postOwnerName': post.postOwnerName,
      'postOwnerPhotoUrl': post.postOwnerPhotoUrl,
    };
  }

  Post.fromMap(Map<String, dynamic> mapData) {
    currentUserUid = mapData['ownerUid'];
    imgUrl = mapData['imgUrl'];
    caption = mapData['caption'];
    location = mapData['location'];
    time = mapData['time'];         // Firestore returns Timestamp when reading
    postOwnerName = mapData['postOwnerName'];
    postOwnerPhotoUrl = mapData['postOwnerPhotoUrl'];
  }
}