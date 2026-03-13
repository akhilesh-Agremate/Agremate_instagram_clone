import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String? ownerName;
  String? ownerPhotoUrl;
  String? comment;
  Timestamp? timeStamp;   // Changed from FieldValue → Timestamp
  String? ownerUid;

  Comment({
    this.ownerName,
    this.ownerPhotoUrl,
    this.comment,
    this.timeStamp,
    this.ownerUid,
  });

  Map<String, dynamic> toMap(Comment comment) {
    var data = <String, dynamic>{};
    data['ownerName'] = comment.ownerName;
    data['ownerPhotoUrl'] = comment.ownerPhotoUrl;
    data['comment'] = comment.comment;
    data['timestamp'] = FieldValue.serverTimestamp(); // Use FieldValue only when writing
    data['ownerUid'] = comment.ownerUid;
    return data;
  }

  Comment.fromMap(Map<String, dynamic> mapData) {
    ownerName = mapData['ownerName'];
    ownerPhotoUrl = mapData['ownerPhotoUrl'];
    comment = mapData['comment'];
    timeStamp = mapData['timestamp'];  // Firestore returns Timestamp when reading
    ownerUid = mapData['ownerUid'];
  }
}