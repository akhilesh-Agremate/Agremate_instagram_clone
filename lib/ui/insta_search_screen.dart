import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_friend_profile_screen.dart';
import 'package:instagram_clone/ui/post_detail_screen.dart';

class InstaSearchScreen extends StatefulWidget {
  const InstaSearchScreen({Key? key}) : super(key: key);

  @override
  _InstaSearchScreenState createState() => _InstaSearchScreenState();
}

class _InstaSearchScreenState extends State<InstaSearchScreen> {
  final _repository = Repository();                                       // var → final
  List<DocumentSnapshot> list = [];
  model.User? _user;                                                      // Aliased, added ?
  model.User? currentUser;                                                // Added ?
  List<model.User> usersList = [];

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      if (user == null) return;                                           // Null guard

      _repository.fetchUserDetailsById(user.uid).then((fetchedUser) {
        setState(() {
          _user = fetchedUser;                                            // Use fetched model user
          currentUser = fetchedUser;
        });
      });

      print("USER : ${user.displayName}");

      _repository.retrievePosts(user).then((updatedList) {
        setState(() => list = updatedList);
      });

      _repository.fetchAllUsers(user).then((fetchedList) {
        setState(() => usersList = fetchedList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("INSIDE BUILD");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Search'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DataSearch(userList: usersList),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        itemCount: list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemBuilder: (context, index) {
          final data = list[index].data() as Map<String, dynamic>;      // .data → .data()
          print("LIST : ${list.length}");
          return GestureDetector(
            onTap: () {
              print("SNAPSHOT : ${list[index].reference.path}");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(
                    user: _user,
                    currentuser: currentUser,
                    documentSnapshot: list[index],
                  ),
                ),
              );
            },
            child: CachedNetworkImage(
              imageUrl: data['imgUrl'] ?? '',                           // Null safety
              placeholder: (context, s) =>
              const Center(child: CircularProgressIndicator()),
              width: 125.0,
              height: 125.0,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final List<model.User> userList;                                       // Added final

  DataSearch({required this.userList});                                  // Added required

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');                                              // null → ''
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);                                    // null → reuse suggestions
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionsList = query.isEmpty
        ? userList
        : userList
        .where((p) =>
        (p.displayName ?? '')
            .toLowerCase()
            .startsWith(query.toLowerCase()))                   // Case-insensitive + null safe
        .toList();

    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InstaFriendProfileScreen(
                name: suggestionsList[index].displayName,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            suggestionsList[index].photoUrl ?? '',                      // Null safety
          ),
        ),
        title: Text(suggestionsList[index].displayName ?? ''),          // Null safety
      ),
    );
  }
}