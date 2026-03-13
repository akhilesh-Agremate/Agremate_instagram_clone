import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/models/like.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/comments_screen.dart';
import 'package:instagram_clone/ui/likes_screen.dart';
import 'package:instagram_clone/ui/post_detail_screen.dart';

class InstaFriendProfileScreen extends StatefulWidget {
  final String? name;

  const InstaFriendProfileScreen({Key? key, this.name}) : super(key: key);

  @override
  _InstaFriendProfileScreenState createState() =>
      _InstaFriendProfileScreenState();
}

class _InstaFriendProfileScreenState
    extends State<InstaFriendProfileScreen> {
  String? currentUserId, followingUserId;
  final _repository = Repository();
  Color _gridColor = Colors.blue;
  Color _listColor = Colors.grey;
  bool _isGridActive = true;
  model.User? _user, currentuser;
  Future<List<DocumentSnapshot>>? _future;
  bool isFollowing = false;

  Future<void> fetchUidBySearchedName(String name) async {
    print("NAME : $name");
    final uid = await _repository.fetchUidBySearchedName(name);
    if (uid == null) return;                                              // Null guard
    setState(() => followingUserId = uid);
    await fetchUserDetailsById(uid);
    setState(() {
      _future = _repository.retrieveUserPosts(uid);
    });
  }

  Future<void> fetchUserDetailsById(String userId) async {
    final user = await _repository.fetchUserDetailsById(userId);
    setState(() {
      _user = user;
      print("USER : ${_user?.displayName}");
    });
  }

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      if (user == null) return;                                           // Null guard
      _repository.fetchUserDetailsById(user.uid).then((currentUser) {
        setState(() => currentuser = currentUser);
      });
      _repository
          .checkIsFollowing(widget.name!, user.uid)
          .then((value) {
        print("VALUE : $value");
        setState(() => isFollowing = value);
      });
      setState(() => currentUserId = user.uid);
    });
    fetchUidBySearchedName(widget.name!);
  }

  void followUser() {
    print('following user');
    _repository.followUser(
      currentUserId: currentUserId,
      followingUserId: followingUserId,
    );
    setState(() => isFollowing = true);
  }

  void unfollowUser() {
    _repository.unFollowUser(
      currentUserId: currentUserId,
      followingUserId: followingUserId,
    );
    setState(() => isFollowing = false);
  }

  Widget buildButton({
    String? text,
    Color? backgroundcolor,
    Color? textColor,
    Color? borderColor,
    VoidCallback? function,                                               // Function → VoidCallback?
  }) {
    return GestureDetector(
      onTap: function,
      child: Container(
        width: 210.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: backgroundcolor,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: borderColor ?? Colors.grey),
        ),
        child: Center(
          child: Text(
            text ?? '',
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  Widget buildProfileButton() {
    if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        backgroundcolor: Colors.white,
        textColor: Colors.black,
        borderColor: Colors.grey,
        function: unfollowUser,
      );
    }
    return buildButton(
      text: "Follow",
      backgroundcolor: Colors.blue,
      textColor: Colors.white,
      borderColor: Colors.blue,
      function: followUser,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xfff8faf8),
          elevation: 1,
          title: const Text('Profile'),
        ),
        body: _user != null
            ? ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding:
                  const EdgeInsets.only(top: 20.0, left: 20.0),
                  child: Container(
                    width: 110.0,
                    height: 110.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80.0),
                      image: DecorationImage(
                        image: (_user!.photoUrl == null ||
                            _user!.photoUrl!.isEmpty)
                            ? const AssetImage('assets/no_image.png')
                        as ImageProvider
                            : NetworkImage(_user!.photoUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          StreamBuilder<List<DocumentSnapshot>>(
                            stream: _repository
                                .fetchStats(
                              uid: followingUserId,
                              label: 'posts',
                            )
                                .asStream(),
                            builder: (context,
                                AsyncSnapshot<List<DocumentSnapshot>>
                                snapshot) {
                              if (snapshot.hasData) {
                                return detailsWidget(
                                  snapshot.data!.length.toString(),
                                  'posts',
                                );
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          ),
                          StreamBuilder<List<DocumentSnapshot>>(
                            stream: _repository
                                .fetchStats(
                              uid: followingUserId,
                              label: 'followers',
                            )
                                .asStream(),
                            builder: (context,
                                AsyncSnapshot<List<DocumentSnapshot>>
                                snapshot) {
                              if (snapshot.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 24.0),
                                  child: detailsWidget(
                                    snapshot.data!.length.toString(),
                                    'followers',
                                  ),
                                );
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          ),
                          StreamBuilder<List<DocumentSnapshot>>(
                            stream: _repository
                                .fetchStats(
                              uid: followingUserId,
                              label: 'following',
                            )
                                .asStream(),
                            builder: (context,
                                AsyncSnapshot<List<DocumentSnapshot>>
                                snapshot) {
                              if (snapshot.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20.0),
                                  child: detailsWidget(
                                    snapshot.data!.length.toString(),
                                    'following',
                                  ),
                                );
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 12.0, left: 20.0, right: 20.0),
                        child: buildProfileButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 30.0),
              child: Text(
                _user!.displayName ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 10.0),
              child: (_user!.bio != null && _user!.bio!.isNotEmpty)
                  ? Text(_user!.bio!)
                  : const SizedBox.shrink(),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isGridActive = true;
                        _gridColor = Colors.blue;
                        _listColor = Colors.grey;
                      });
                    },
                    child: Icon(Icons.grid_on, color: _gridColor),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isGridActive = false;
                        _listColor = Colors.blue;
                        _gridColor = Colors.grey;
                      });
                    },
                    child: Icon(
                      Icons.stay_current_portrait,
                      color: _listColor,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: postImagesWidget(),
            ),
          ],
        )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget postImagesWidget() {
    return _isGridActive
        ? FutureBuilder<List<DocumentSnapshot>>(
      future: _future,
      builder: (context,
          AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return GridView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemBuilder: (context, index) {
              final data = snapshot.data![index].data()
              as Map<String, dynamic>;                         // .data → .data()
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(
                        user: _user,
                        currentuser: currentuser,
                        documentSnapshot: snapshot.data![index],
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: data['imgUrl'] ?? '',
                  placeholder: (context, s) => const Center(
                      child: CircularProgressIndicator()),
                  width: 125.0,
                  height: 125.0,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('No Posts Found'));
        }
        return const Center(child: CircularProgressIndicator());
      },
    )
        : FutureBuilder<List<DocumentSnapshot>>(
      future: _future,
      builder: (context,
          AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return SizedBox(
            height: 600.0,
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => ListItem(
                list: snapshot.data!,
                index: index,
                user: _user,
                currentuser: currentuser,
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget detailsWidget(String count, String label) {
    return Column(
      children: <Widget>[
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.black,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class ListItem extends StatefulWidget {
  final List<DocumentSnapshot> list;
  final model.User? user, currentuser;
  final int index;

  const ListItem({                                                        // Added const + final
    Key? key,
    required this.list,
    this.user,
    this.index = 0,
    this.currentuser,
  }) : super(key: key);

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _repository = Repository();
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    print("INDEX : ${widget.index}");
  }

  Widget commentWidget(DocumentReference reference) {
    return FutureBuilder<List<DocumentSnapshot>>(
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
                    user: widget.currentuser,
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

  @override
  Widget build(BuildContext context) {
    final data =
    widget.list[widget.index].data() as Map<String, dynamic>;       // .data → .data()

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
                  Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(
                            widget.user?.photoUrl ?? ''),               // Null safety
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.user?.displayName ?? '',
                        style:
                        const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (data['location'] != null)
                        Text(
                          data['location'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ],
              ),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: null),
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
                        postLike(widget.list[widget.index].reference);
                      } else {
                        setState(() => _isLiked = false);
                        postUnlike(widget.list[widget.index].reference);
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
                            documentReference:
                            widget.list[widget.index].reference,
                            user: widget.currentuser,
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
        FutureBuilder<List<DocumentSnapshot>>(
          future: _repository
              .fetchPostLikes(widget.list[widget.index].reference),
          builder: (context,
              AsyncSnapshot<List<DocumentSnapshot>> likesSnapshot) {
            if (likesSnapshot.hasData) {
              final likes = likesSnapshot.data!;
              final likeData = likes.isNotEmpty
                  ? likes[0].data() as Map<String, dynamic>
                  : null;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LikesScreen(
                        user: widget.user,
                        documentReference:
                        widget.list[widget.index].reference,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
                  child: likes.length > 1
                      ? Text(
                    "Liked by ${likeData?['ownerName']} and ${likes.length - 1} others",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 8.0),
          child: data['caption'] != null
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                children: <Widget>[
                  Text(
                    widget.user?.displayName ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(data['caption'] ?? ''),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: commentWidget(
                    widget.list[widget.index].reference),
              ),
            ],
          )
              : commentWidget(widget.list[widget.index].reference),
        ),
        const Padding(
          padding:
          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "1 Day Ago",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  void postLike(DocumentReference reference) {
    var _like = Like(
      ownerName: widget.currentuser?.displayName,
      ownerPhotoUrl: widget.currentuser?.photoUrl,
      ownerUid: widget.currentuser?.uid,
      timeStamp: Timestamp.now(),                                       // FieldValue → Timestamp.now()
    );
    reference
        .collection('likes')
        .doc(widget.currentuser?.uid)                                   // .document() → .doc()
        .set(_like.toMap(_like))                                        // .setData() → .set()
        .then((_) => print("Post Liked"));
  }

  void postUnlike(DocumentReference reference) {
    reference
        .collection("likes")
        .doc(widget.currentuser?.uid)
        .delete()
        .then((_) => print("Post Unliked"));
  }
}
