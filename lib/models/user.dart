class User {
  String? uid;
  String? email;
  String? photoUrl;
  String? displayName;
  String? followers;
  String? following;
  String? posts;
  String? bio;
  String? phone;

  User({
    this.uid,
    this.email,
    this.photoUrl,
    this.displayName,
    this.followers,
    this.following,
    this.bio,
    this.posts,
    this.phone,
  });

  Map<String, dynamic> toMap(User user) {
    return {
      'uid': user.uid,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'displayName': user.displayName,
      'followers': user.followers,
      'following': user.following,
      'bio': user.bio,
      'posts': user.posts,
      'phone': user.phone,
    };
  }

  User.fromMap(Map<String, dynamic> mapData) {
    uid = mapData['uid'];
    email = mapData['email'];
    photoUrl = mapData['photoUrl'];
    displayName = mapData['displayName'];
    followers = mapData['followers'];
    following = mapData['following'];
    bio = mapData['bio'];
    posts = mapData['posts'];
    phone = mapData['phone'];
  }
}