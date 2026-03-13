import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/message.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/firebase_provider.dart';

class Repository {
  final _firebaseProvider = FirebaseProvider();

  Future<void> addDataToDb(User user) =>                                  // FirebaseUser → User
  _firebaseProvider.addDataToDb(user);

  Future<User?> signIn() =>                                               // FirebaseUser → User?
  _firebaseProvider.signIn();

  Future<bool> authenticateUser(User user) =>                             // FirebaseUser → User
  _firebaseProvider.authenticateUser(user);

  Future<User?> getCurrentUser() =>                                       // FirebaseUser → User?
  _firebaseProvider.getCurrentUser();

  Future<void> signOut() =>
      _firebaseProvider.signOut();

  Future<String> uploadImageToStorage(File imageFile) =>
      _firebaseProvider.uploadImageToStorage(imageFile);

  Future<void> addPostToDb(
      model.User currentUser,                                               // Aliased to avoid clash
      String imgUrl,
      String caption,
      String location,
      ) => _firebaseProvider.addPostToDb(currentUser, imgUrl, caption, location);

  Future<model.User> retrieveUserDetails(User user) =>                   // FirebaseUser → User
  _firebaseProvider.retrieveUserDetails(user);

  Future<List<DocumentSnapshot>> retrieveUserPosts(String userId) =>
      _firebaseProvider.retrieveUserPosts(userId);

  Future<List<DocumentSnapshot>> fetchPostComments(
      DocumentReference reference,
      ) => _firebaseProvider.fetchPostCommentDetails(reference);

  Future<List<DocumentSnapshot>> fetchPostLikes(
      DocumentReference reference,
      ) => _firebaseProvider.fetchPostLikeDetails(reference);

  Future<bool> checkIfUserLikedOrNot(
      String userId,
      DocumentReference reference,
      ) => _firebaseProvider.checkIfUserLikedOrNot(userId, reference);

  Future<List<DocumentSnapshot>> retrievePosts(User user) =>             // FirebaseUser → User
  _firebaseProvider.retrievePosts(user);

  Future<List<String>> fetchAllUserNames(User user) =>                   // FirebaseUser → User
  _firebaseProvider.fetchAllUserNames(user);

  Future<String?> fetchUidBySearchedName(String name) =>                 // String → String?
  _firebaseProvider.fetchUidBySearchedName(name);

  Future<model.User> fetchUserDetailsById(String uid) =>
      _firebaseProvider.fetchUserDetailsById(uid);

  Future<void> followUser({
    String? currentUserId,                                                // Added ?
    String? followingUserId,                                              // Added ?
  }) => _firebaseProvider.followUser(
    currentUserId: currentUserId,
    followingUserId: followingUserId,
  );

  Future<void> unFollowUser({
    String? currentUserId,                                                // Added ?
    String? followingUserId,                                              // Added ?
  }) => _firebaseProvider.unFollowUser(
    currentUserId: currentUserId,
    followingUserId: followingUserId,
  );

  Future<bool> checkIsFollowing(String name, String currentUserId) =>
      _firebaseProvider.checkIsFollowing(name, currentUserId);

  Future<List<DocumentSnapshot>> fetchStats({
    String? uid,                                                          // Added ?
    String? label,                                                        // Added ?
  }) => _firebaseProvider.fetchStats(uid: uid, label: label);

  Future<void> updatePhoto(String photoUrl, String uid) =>
      _firebaseProvider.updatePhoto(photoUrl, uid);

  Future<void> updateDetails(
      String uid,
      String name,
      String bio,
      String email,
      String phone,
      ) => _firebaseProvider.updateDetails(uid, name, bio, email, phone);

  Future<List<String>> fetchUserNames(User user) =>                      // FirebaseUser → User
  _firebaseProvider.fetchUserNames(user);

  Future<List<model.User>> fetchAllUsers(User user) =>                   // FirebaseUser → User
  _firebaseProvider.fetchAllUsers(user);

  void uploadImageMsgToDb(
      String url,
      String receiverUid,
      String senderUid,
      ) => _firebaseProvider.uploadImageMsgToDb(url, receiverUid, senderUid);

  Future<void> addMessageToDb(Message message, String receiverUid) =>
      _firebaseProvider.addMessageToDb(message, receiverUid);

  Future<List<DocumentSnapshot>> fetchFeed(User user) =>                 // FirebaseUser → User
  _firebaseProvider.fetchFeed(user);

  Future<List<String>> fetchFollowingUids(User user) =>                  // FirebaseUser → User
  _firebaseProvider.fetchFollowingUids(user);
}