import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/like.dart';
import 'package:instagram_clone/models/message.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart' as model;

class FirebaseProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Updated
  model.User? user;
  Post? post;
  Like? like;
  Message? _message;
  Comment? comment;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance; // Updated to singleton
  Reference? _storageReference; // Updated from StorageReference

  Future<void> addDataToDb(User currentUser) async {
    // Updated FirebaseUser → User
    print("Inside addDataToDb Method");

    _firestore
        .collection("display_names")
        .doc(currentUser.displayName) // .document() → .doc()
        .set({'displayName': currentUser.displayName}); // .setData() → .set()

    user = model.User(
        uid: currentUser.uid,
        email: currentUser.email,
        displayName: currentUser.displayName,
        photoUrl: currentUser.photoURL, // photoUrl → photoURL
        followers: '0',
        following: '0',
        bio: '',
        posts: '0',
        phone: '');

    return _firestore
        .collection("users")
        .doc(currentUser.uid)
        .set(user!.toMap(user!)); // .document() → .doc(), .setData() → .set()
  }

  Future<bool> authenticateUser(User user) async {
    // Updated FirebaseUser → User
    print("Inside authenticateUser");
    final QuerySnapshot result = await _firestore
        .collection("users")
        .where("email", isEqualTo: user.email)
        .get(); // .getDocuments() → .get()

    final List<DocumentSnapshot> docs = result.docs; // .documents → .docs

    return docs.isEmpty;
  }

  Future<User?> getCurrentUser() async {
    // Updated return type
    User? currentUser = _auth.currentUser; // No longer async
    print("EMAIL ID : ${currentUser?.email}");
    return currentUser;
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

  Future<User?> signIn() async {
    // Updated to use authenticate() and authorizationClient for accessToken in google_sign_in 7.x
    GoogleSignInAccount _signInAccount = await _googleSignIn.authenticate();
    GoogleSignInAuthentication _signInAuthentication =
    await _signInAccount.authentication;

    final authz = await _signInAccount.authorizationClient.authorizeScopes([]);

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: authz.accessToken,
      idToken: _signInAuthentication.idToken,
    );

    final UserCredential userCredential =
    await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask =
    _storageReference!.putFile(imageFile); // Updated StorageUploadTask → UploadTask
    String url =
    await (await uploadTask).ref.getDownloadURL(); // Updated .onComplete
    return url;
  }

  Future<void> addPostToDb(
      model.User currentUser, String imgUrl, String caption, String location) {
    CollectionReference _collectionRef = _firestore
        .collection("users")
        .doc(currentUser.uid)
        .collection("posts");

    post = Post(
        currentUserUid: currentUser.uid,
        imgUrl: imgUrl,
        caption: caption,
        location: location,
        postOwnerName: currentUser.displayName,
        postOwnerPhotoUrl: currentUser.photoUrl,
        time: Timestamp.now()); // FieldValue.serverTimestamp() → Timestamp.now()

    return _collectionRef.add(post!.toMap(post!));
  }

  Future<model.User> retrieveUserDetails(User user) async {
    DocumentSnapshot _documentSnapshot =
    await _firestore.collection("users").doc(user.uid).get();
    return model.User.fromMap(_documentSnapshot.data() as Map<String, dynamic>); // .data → .data()
  }

  Future<List<DocumentSnapshot>> retrieveUserPosts(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("posts")
        .get();
    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> fetchPostCommentDetails(
      DocumentReference reference) async {
    QuerySnapshot snapshot = await reference.collection("comments").get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> fetchPostLikeDetails(
      DocumentReference reference) async {
    print("REFERENCE : ${reference.path}");
    QuerySnapshot snapshot = await reference.collection("likes").get();
    return snapshot.docs;
  }

  Future<bool> checkIfUserLikedOrNot(
      String userId, DocumentReference reference) async {
    DocumentSnapshot snapshot =
    await reference.collection("likes").doc(userId).get();
    print('DOC ID : ${snapshot.reference.path}');
    return snapshot.exists;
  }

  Future<List<DocumentSnapshot>> retrievePosts(User user) async {
    List<DocumentSnapshot> list = [];
    List<DocumentSnapshot> updatedList = [];
    QuerySnapshot querySnapshot;
    QuerySnapshot snapshot = await _firestore.collection("users").get();

    for (int i = 0; i < snapshot.docs.length; i++) {
      if (snapshot.docs[i].id != user.uid) {
        // .documentID → .id
        list.add(snapshot.docs[i]);
      }
    }
    for (var i = 0; i < list.length; i++) {
      querySnapshot = await list[i].reference.collection("posts").get();
      for (var j = 0; j < querySnapshot.docs.length; j++) {
        updatedList.add(querySnapshot.docs[j]);
      }
    }
    print("UPDATED LIST LENGTH : ${updatedList.length}");
    return updatedList;
  }

  Future<List<String>> fetchAllUserNames(User user) async {
    List<String> userNameList = [];
    QuerySnapshot querySnapshot = await _firestore.collection("users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != user.uid) {
        final data = querySnapshot.docs[i].data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('displayName')) {
          userNameList.add(data['displayName'] as String);
        }
      }
    }
    print("USERNAMES LIST : ${userNameList.length}");
    return userNameList;
  }

  Future<String?> fetchUidBySearchedName(String name) async {
    String? uid;
    List<DocumentSnapshot> uidList = [];

    QuerySnapshot querySnapshot = await _firestore.collection("users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      uidList.add(querySnapshot.docs[i]);
    }

    for (var i = 0; i < uidList.length; i++) {
      if ((uidList[i].data() as Map<String, dynamic>)['displayName'] == name) {
        uid = uidList[i].id;
      }
    }
    print("UID DOC ID: $uid");
    return uid;
  }

  Future<model.User> fetchUserDetailsById(String uid) async {
    DocumentSnapshot documentSnapshot =
    await _firestore.collection("users").doc(uid).get();
    return model.User.fromMap(
        documentSnapshot.data() as Map<String, dynamic>);
  }

  Future<void> followUser(
      {String? currentUserId, String? followingUserId}) async {
    await _firestore
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .doc(followingUserId)
        .set({'uid': followingUserId});

    return _firestore
        .collection("users")
        .doc(followingUserId)
        .collection("followers")
        .doc(currentUserId)
        .set({'uid': currentUserId});
  }

  Future<void> unFollowUser(
      {String? currentUserId, String? followingUserId}) async {
    await _firestore
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .doc(followingUserId)
        .delete();

    return _firestore
        .collection("users")
        .doc(followingUserId)
        .collection("followers")
        .doc(currentUserId)
        .delete();
  }

  Future<bool> checkIsFollowing(String name, String currentUserId) async {
    bool isFollowing = false;
    String? uid = await fetchUidBySearchedName(name);
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id == uid) {
        isFollowing = true;
      }
    }
    return isFollowing;
  }

  Future<List<DocumentSnapshot>> fetchStats(
      {String? uid, String? label}) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(uid)
        .collection(label!)
        .get();
    return querySnapshot.docs;
  }

  Future<void> updatePhoto(String photoUrl, String uid) async {
    return _firestore
        .collection("users")
        .doc(uid)
        .update({'photoUrl': photoUrl}); // .updateData() → .update()
  }

  Future<void> updateDetails(
      String uid, String name, String bio, String email, String phone) async {
    return _firestore.collection("users").doc(uid).update({
      'displayName': name,
      'bio': bio,
      'email': email,
      'phone': phone,
    });
  }

  Future<List<String>> fetchUserNames(User user) async {
    DocumentReference documentReference =
    _firestore.collection("messages").doc(user.uid);
    List<String> userNameList = [];
    List<String> chatUsersList = [];
    QuerySnapshot querySnapshot = await _firestore.collection("users").get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != user.uid) {
        userNameList.add(querySnapshot.docs[i].id);
      }
    }

    for (var i = 0; i < userNameList.length; i++) {
      final snapshot = await documentReference
          .collection(userNameList[i])
          .limit(1)
          .get(); // Properly check if subcollection has docs
      if (snapshot.docs.isNotEmpty) {
        chatUsersList.add(userNameList[i]);
      }
    }

    print("CHAT USERS LIST : ${chatUsersList.length}");
    return chatUsersList;
  }

  Future<List<model.User>> fetchAllUsers(User user) async {
    List<model.User> userList = [];
    QuerySnapshot querySnapshot = await _firestore.collection("users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != user.uid) {
        userList.add(model.User.fromMap(
            querySnapshot.docs[i].data() as Map<String, dynamic>));
      }
    }
    print("USERSLIST : ${userList.length}");
    return userList;
  }

  void uploadImageMsgToDb(String url, String receiverUid, String senderUid) {
    _message = Message.withoutMessage(
        receiverUid: receiverUid,
        senderUid: senderUid,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: 'image');

    var map = <String, dynamic>{
      'senderUid': _message!.senderUid,
      'receiverUid': _message!.receiverUid,
      'type': _message!.type,
      'timestamp': _message!.timestamp,
      'photoUrl': _message!.photoUrl,
    };

    _firestore
        .collection("messages")
        .doc(_message!.senderUid)
        .collection(receiverUid)
        .add(map)
        .whenComplete(() => print("Message added to db"));

    _firestore
        .collection("messages")
        .doc(receiverUid)
        .collection(_message!.senderUid!)
        .add(map)
        .whenComplete(() => print("Message added to db"));
  }

  Future<void> addMessageToDb(Message message, String receiverUid) async {
    var map = message.toMap();
    await _firestore
        .collection("messages")
        .doc(message.senderUid)
        .collection(receiverUid)
        .add(map);

    await _firestore
        .collection("messages")
        .doc(receiverUid)
        .collection(message.senderUid!)
        .add(map);
  }

  Future<List<DocumentSnapshot>> fetchFeed(User user) async {
    List<String> followingUIDs = [];
    List<DocumentSnapshot> list = [];

    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("following")
        .get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      followingUIDs.add(querySnapshot.docs[i].id);
    }

    for (var i = 0; i < followingUIDs.length; i++) {
      QuerySnapshot postSnapshot = await _firestore
          .collection("users")
          .doc(followingUIDs[i])
          .collection("posts")
          .get();
      for (var j = 0; j < postSnapshot.docs.length; j++) {
        list.add(postSnapshot.docs[j]);
      }
    }
    return list;
  }

  Future<List<String>> fetchFollowingUids(User user) async {
    List<String> followingUIDs = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("following")
        .get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      followingUIDs.add(querySnapshot.docs[i].id);
    }
    return followingUIDs;
  }
}
