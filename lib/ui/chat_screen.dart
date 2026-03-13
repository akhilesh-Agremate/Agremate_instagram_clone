import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _repository = Repository();                        // var → final
  List<model.User> usersList = [];                         // Aliased, removed deprecated List<User>()

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      if (user == null) return;                            // Null guard
      print("USER : ${user.displayName}");
      _repository.fetchAllUsers(user).then((updatedList) {
        setState(() {
          usersList = updatedList;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                delegate: ChatSearch(usersList: usersList),
              );
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: usersList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(
                      photoUrl: usersList[index].photoUrl,
                      name: usersList[index].displayName,
                      receiverUid: usersList[index].uid,
                    ),
                  ),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    usersList[index].photoUrl ?? '',      // Null safety
                  ),
                ),
                title: Text(usersList[index].displayName ?? ''), // Null safety
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatSearch extends SearchDelegate<String> {
  final List<model.User> usersList;                        // Added final

  ChatSearch({required this.usersList});                   // Added required

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
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
        close(context, '');                               // null → '' (non-nullable)
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);                     // null → reuse suggestions
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<model.User> suggestionsList = query.isEmpty
        ? usersList
        : usersList
        .where((p) =>
        (p.displayName ?? '').toLowerCase()
            .startsWith(query.toLowerCase())) // Case-insensitive search
        .toList();

    return ListView.builder(
      itemCount: suggestionsList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                photoUrl: suggestionsList[index].photoUrl,
                name: suggestionsList[index].displayName,
                receiverUid: suggestionsList[index].uid,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            suggestionsList[index].photoUrl ?? '',        // Null safety
          ),
        ),
        title: Text(suggestionsList[index].displayName ?? ''), // Null safety
      ),
    );
  }
}