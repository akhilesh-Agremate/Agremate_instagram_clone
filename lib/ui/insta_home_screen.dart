import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/ui/insta_activity_screen.dart';
import 'package:instagram_clone/ui/insta_add_screen.dart';
import 'package:instagram_clone/ui/insta_feed_screen.dart';
import 'package:instagram_clone/ui/insta_profile_screen.dart';
import 'package:instagram_clone/ui/insta_search_screen.dart';

class InstaHomeScreen extends StatefulWidget {
  const InstaHomeScreen({Key? key}) : super(key: key);

  @override
  _InstaHomeScreenState createState() => _InstaHomeScreenState();
}

class _InstaHomeScreenState extends State<InstaHomeScreen> {
  late PageController pageController;                                     // Moved inside state, added late
  int _page = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();                                    // Removed new
  }

  @override
  void dispose() {
    pageController.dispose();                                             // Moved before super
    super.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() => _page = page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(                                                     // Removed new
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
        children: const [                                                 // Added const
          ColoredBox(                                                     // Container(color:) → ColoredBox
            color: Colors.white,
            child: InstaFeedScreen(),
          ),
          ColoredBox(
            color: Colors.white,
            child: InstaSearchScreen(),
          ),
          ColoredBox(
            color: Colors.white,
            child: InstaAddScreen(),
          ),
          ColoredBox(
            color: Colors.white,
            child: InstaActivityScreen(),
          ),
          ColoredBox(
            color: Colors.white,
            child: InstaProfileScreen(),
          ),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(                              // Removed new
        activeColor: Colors.orange,
        currentIndex: _page,
        onTap: navigationTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _page == 0 ? Colors.black : Colors.grey,
            ),
            label: '',                                                    // title → label
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: _page == 1 ? Colors.black : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle,
              color: _page == 2 ? Colors.black : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.star,
              color: _page == 3 ? Colors.black : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _page == 4 ? Colors.black : Colors.grey,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}