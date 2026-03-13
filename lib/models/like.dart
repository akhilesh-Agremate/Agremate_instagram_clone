import 'package:cloud_firestore/cloud_firestore.dart';

class Like {
  String? ownerName;
  String? ownerPhotoUrl;
  String? ownerUid;
  Timestamp? timeStamp; // Changed from FieldValue → Timestamp

  Like({
    this.ownerName,
    this.ownerPhotoUrl,
    this.ownerUid,
    this.timeStamp,
  });

  Map<String, dynamic> toMap(Like like) {
    var data = <String, dynamic>{};
    data['ownerName'] = like.ownerName;
    data['ownerPhotoUrl'] = like.ownerPhotoUrl;
    data['ownerUid'] = like.ownerUid;
    data['timestamp'] = FieldValue.serverTimestamp(); // FieldValue only when writing
    return data;
  }

  Like.fromMap(Map<String, dynamic> mapData) {
    ownerName = mapData['ownerName'];
    ownerPhotoUrl = mapData['ownerPhotoUrl'];
    ownerUid = mapData['ownerUid'];
    timeStamp = mapData['timestamp']; // Firestore returns Timestamp when reading
  }
}