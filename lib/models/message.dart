import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? senderUid;
  String? receiverUid;
  String? type;
  String? message;
  Timestamp? timestamp; // Changed from FieldValue → Timestamp
  String? photoUrl;

  Message({
    this.senderUid,
    this.receiverUid,
    this.type,
    this.message,
    this.timestamp,
  });

  Message.withoutMessage({
    this.senderUid,
    this.receiverUid,
    this.type,
    this.timestamp,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'type': type,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(), // FieldValue only when writing
      'photoUrl': photoUrl,
    };
  }

  // Changed to a factory constructor (better practice for fromMap)
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderUid: map['senderUid'],
      receiverUid: map['receiverUid'],
      type: map['type'],
      message: map['message'],
      timestamp: map['timestamp'],
    );
  }
}