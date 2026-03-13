import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/models/like.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/chat_screen.dart';
import 'package:instagram_clone/ui/comments_screen.dart';
import 'package:instagram_clone/ui/insta_friend_profile_screen.dart';
import 'package:instagram_clone/ui/likes_screen.dart';

class InstaFeedScreen extends StatefulWidget {
  const InstaFeedScreen({Key? key}) : super(key: key);

  @override
  _InstaFeedScreenState createState() => _InstaFeedScreenState();
}

class _InstaFeedScreenState extends State<InstaFeedScreen> {
  final _repository = Repository();                                         // var → final
  model.User? currentUser, user, followingUser;                             // Aliased, added ?
  List<model.User> usersList = [];
  Future<List<DocumentSnapshot>>? _future;                                  // Added ?
  bool _isLiked = false;
  List<String> followingUIDs = [];

  @override
  void initState() {
    super.initState();
    fetchFeed();
  }

  void fetchFeed() async {
    final authUser = await _repository.getCurrentUser();
    if (authUser == null) return;                                           // Null guard

    final user = await _repository.fetchUserDetailsById(authUser.uid);
    setState(() => currentUser = user);

    followingUIDs = await _repository.fetchFollowingUids(authUser);

    for (var i = 0; i < followingUIDs.length; i++) {
      print("DSDASDASD : ${followingUIDs[i]}");
      this.user = await _repository.fetchUserDetailsById(followingUIDs[i]);
      print("user : ${this.user?.uid}");
      usersList.add(this.user!);
      print("USERSLIST : ${usersList.length}");

      for (var j = 0; j < usersList.length; j++) {                        // Fixed shadowed i → j
        setState(() {
          followingUser = usersList[j];
          print("FOLLOWING USER : ${followingUser?.uid}");
        });
      }
    }

    setState(() {
      _future = _repository.fetchFeed(authUser);                           // Wrapped in setState
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff8faf8),
        centerTitle: true,
        elevation: 1.0,
        leading: const Icon(Icons.camera_alt),
        title: SizedBox(
          height: 35.0,
          child: Image.asset("assets/insta_logo.png"),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: currentUser != null
          ? Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: postImagesWidget(),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget postImagesWidget() {
    return FutureBuilder<List<DocumentSnapshot>>(                          // Added type
      future: _future,
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: snapshot.data!.length,                             // Added !
            itemBuilder: (context, index) => listItem(
              list: snapshot.data!,
              index: index,
              user: followingUser,
              currentUser: currentUser,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget listItem({
    List<DocumentSnapshot>? list,
    model.User? user,
    model.User? currentUser,
    int? index,
  }) {
    final data = list![index!].data() as Map<String, dynamic>;            // .data → .data()
    print("dadadadad : ${user?.uid}");

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InstaFriendProfileScreen(
                            name: data['postOwnerName'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                            data['postOwnerPhotoUrl'] ?? '',               // Null safety
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InstaFriendProfileScreen(
                                name: data['postOwnerName'],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          data['postOwnerName'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (data['location'] != null)                       // Cleaner null check
                        Text(
                          data['location'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: null,
              ),
            ],
          ),
        ),
        CachedNetworkImage(
          imageUrl: data['imgUrl'] ?? '',
          placeholder: (context, s) =>
          const Center(child: CircularProgressIndicator()),
          width: 125.0,
          height: 250.0,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (!_isLiked) {
                        setState(() => _isLiked = true);
                        postLike(list[index].reference, currentUser!);
                      } else {
                        setState(() => _isLiked = false);
                        postUnlike(list[index].reference, currentUser!);
                      }
                    },
                    child: _isLiked
                        ? const Icon(Icons.favorite, color: Colors.red)
                        : const FaIcon(FontAwesomeIcons.heart),
                  ),
                  const SizedBox(width: 16.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            documentReference: list[index].reference,
                            user: currentUser,
                          ),
                        ),
                      );
                    },
                    child: const FaIcon(FontAwesomeIcons.comment),
                  ),
                  const SizedBox(width: 16.0),
                  const FaIcon(FontAwesomeIcons.paperPlane),
                ],
              ),
              const FaIcon(FontAwesomeIcons.bookmark),
            ],
          ),
        ),
        FutureBuilder<List<DocumentSnapshot>>(                            // Added type
          future: _repository.fetchPostLikes(list[index].reference),
          builder: (context,
              AsyncSnapshot<List<DocumentSnapshot>> likesSnapshot) {
            if (likesSnapshot.hasData) {
              final likes = likesSnapshot.data!;
              final likeData = likes.isNotEmpty
                  ? likes[0].data() as Map<String, dynamic>              // .data → .data()
                  : null;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LikesScreen(
                        user: currentUser,
                        documentReference: list[index].reference,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: likes.length > 1
                      ? Text(
                    "Liked by ${likeData?['ownerName']} and ${likes.length - 1} others",
                    style:
                    const TextStyle(fontWeight: FontWeight.bold),
                  )
                      : Text(
                    likes.length == 1
                        ? "Liked by ${likeData?['ownerName']}"
                        : "0 Likes",
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: data['caption'] != null
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                children: <Widget>[
                  Text(
                    data['postOwnerName'] ?? '',
                    style:
                    const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(data['caption'] ?? ''),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: commentWidget(list[index].reference),
              ),
            ],
          )
              : commentWidget(list[index].reference),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text("1 Day Ago", style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget commentWidget(DocumentReference reference) {
    return FutureBuilder<List<DocumentSnapshot>>(                         // Added type
      future: _repository.fetchPostComments(reference),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentsScreen(
                    documentReference: reference,
                    user: currentUser,
                  ),
                ),
              );
            },
            child: Text(
              'View all ${snapshot.data!.length} comments',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void postLike(DocumentReference reference, model.User currentUser) {
    var _like = Like(
      ownerName: currentUser.displayName,
      ownerPhotoUrl: currentUser.photoUrl,
      ownerUid: currentUser.uid,
      timeStamp: Timestamp.now(),                                         // FieldValue → Timestamp.now()
    );
    reference
        .collection('likes')
        .doc(currentUser.uid)                                             // .document() → .doc()
        .set(_like.toMap(_like))                                          // .setData() → .set()
        .then((_) => print("Post Liked"));
  }

  void postUnlike(DocumentReference reference, model.User currentUser) {
    reference
        .collection("likes")
        .doc(currentUser.uid)
        .delete()
        .then((_) => print("Post Unliked"));
  }
}
