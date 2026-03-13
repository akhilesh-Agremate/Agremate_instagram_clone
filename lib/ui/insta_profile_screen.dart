import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/models/like.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/comments_screen.dart';
import 'package:instagram_clone/ui/edit_profile_screen.dart';
import 'package:instagram_clone/ui/likes_screen.dart';
import 'package:instagram_clone/ui/post_detail_screen.dart';
import 'package:instagram_clone/main.dart';

class InstaProfileScreen extends StatefulWidget {
  const InstaProfileScreen({Key? key}) : super(key: key);

  @override
  _InstaProfileScreenState createState() => _InstaProfileScreenState();
}

class _InstaProfileScreenState extends State<InstaProfileScreen> {
  final _repository = Repository();                                       // var → final
  Color _gridColor = Colors.blue;
  Color _listColor = Colors.grey;
  bool _isGridActive = true;
  model.User? _user;                                                      // Aliased, added ?
  Future<List<DocumentSnapshot>>? _future;                                // Added ?

  @override
  void initState() {
    super.initState();
    retrieveUserDetails();
  }

  Future<void> retrieveUserDetails() async {                             // Added return type
    final currentUser = await _repository.getCurrentUser();
    if (currentUser == null) return;                                     // Null guard
    final user = await _repository.retrieveUserDetails(currentUser);
    setState(() {
      _user = user;
      _future = _repository.retrieveUserPosts(_user!.uid!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xfff8faf8),
          elevation: 1,
          title: const Text('Profile'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings_power),
              color: Colors.black,
              onPressed: () {
                _repository.signOut().then((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                });
              },
            ),
          ],
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
                        as ImageProvider               // Cast for type compat
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
                              uid: _user!.uid,
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
                              uid: _user!.uid,
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
                              uid: _user!.uid,
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                photoUrl: _user!.photoUrl,
                                email: _user!.email,
                                bio: _user!.bio,
                                name: _user!.displayName,
                                phone: _user!.phone,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 12.0, left: 20.0, right: 20.0),
                          child: Container(
                            width: 210.0,
                            height: 30.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(4.0),
                              border:
                              Border.all(color: Colors.grey),
                            ),
                            child: const Center(
                              child: Text(
                                'Edit Profile',
                                style:
                                TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
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
        ? FutureBuilder<List<DocumentSnapshot>>(                        // Added type
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
              as Map<String, dynamic>;                       // .data → .data()
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(
                        user: _user,
                        currentuser: _user,
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
  final model.User? user;
  final int index;

  const ListItem({                                                       // Added const + final
    Key? key,
    required this.list,
    this.user,
    this.index = 0,
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
                    user: widget.user,
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
    widget.list[widget.index].data() as Map<String, dynamic>;      // .data → .data()

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
                            widget.user?.photoUrl ?? ''),             // Null safety
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
                            user: widget.user,
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
    final _like = Like(
      ownerName: widget.user?.displayName,
      ownerPhotoUrl: widget.user?.photoUrl,
      ownerUid: widget.user?.uid,
      timeStamp: Timestamp.now(),                                       // FieldValue → Timestamp.now()
    );
    reference
        .collection('likes')
        .doc(widget.user?.uid)                                         // .document() → .doc()
        .set(_like.toMap(_like))                                       // .setData() → .set()
        .then((_) => print("Post Liked"));
  }

  void postUnlike(DocumentReference reference) {
    reference
        .collection("likes")
        .doc(widget.user?.uid)
        .delete()
        .then((_) => print("Post Unliked"));
  }
}
