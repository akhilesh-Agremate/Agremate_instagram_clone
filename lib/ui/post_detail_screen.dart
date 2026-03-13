import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/models/like.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/comments_screen.dart';
import 'package:instagram_clone/ui/likes_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final DocumentSnapshot? documentSnapshot;
  final model.User? user, currentuser;

  const PostDetailScreen({
    Key? key,
    this.documentSnapshot,
    this.user,
    this.currentuser,
  }) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _repository = Repository();                                     // var → final
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    final data =
    widget.documentSnapshot!.data() as Map<String, dynamic>;      // .data → .data()

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: const Color(0xfff8faf8),
        title: const Text('Photo'),
      ),
      body: Column(
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
                            data['postOwnerPhotoUrl'] ?? '',           // Null safety
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          data['postOwnerName'] ?? '',
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
                          postLike(widget.documentSnapshot!.reference);
                        } else {
                          setState(() => _isLiked = false);
                          postUnlike(widget.documentSnapshot!.reference);
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
                              widget.documentSnapshot!.reference,
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
          FutureBuilder<List<DocumentSnapshot>>(                       // Added type
            future: _repository
                .fetchPostLikes(widget.documentSnapshot!.reference),
            builder: (context,
                AsyncSnapshot<List<DocumentSnapshot>> likesSnapshot) {
              if (likesSnapshot.hasData) {
                final likes = likesSnapshot.data!;
                final likeData = likes.isNotEmpty
                    ? likes[0].data() as Map<String, dynamic>          // .data → .data()
                    : null;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LikesScreen(
                          user: widget.currentuser,
                          documentReference:
                          widget.documentSnapshot!.reference,
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
                      data['postOwnerName'] ?? '',
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
                      widget.documentSnapshot!.reference),
                ),
              ],
            )
                : commentWidget(widget.documentSnapshot!.reference),
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
      ),
    );
  }

  Widget commentWidget(DocumentReference reference) {
    return FutureBuilder<List<DocumentSnapshot>>(                      // Added type
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

  void postLike(DocumentReference reference) {
    final _like = Like(
      ownerName: widget.currentuser?.displayName,
      ownerPhotoUrl: widget.currentuser?.photoUrl,
      ownerUid: widget.currentuser?.uid,
      timeStamp: Timestamp.now(),                                      // FieldValue → Timestamp.now()
    );
    reference
        .collection('likes')
        .doc(widget.currentuser?.uid)                                  // .document() → .doc()
        .set(_like.toMap(_like))                                       // .setData() → .set()
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
