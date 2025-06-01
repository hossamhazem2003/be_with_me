import 'package:be_with_me_new_new/features/helper/presintation/pages/chats_list_screen.dart';
import 'package:be_with_me_new_new/features/helper/presintation/pages/posts_screen.dart';
import 'package:be_with_me_new_new/features/helper/presintation/pages/people_screen.dart';
import 'package:be_with_me_new_new/features/helper/presintation/pages/profile_screen.dart';
import 'package:be_with_me_new_new/core/const/app_colors.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    PostsScreen(),
    PeopleScreen(),
    CallsHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BeWithMeColors.backGroundColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: BeWithMeColors.mainColor,
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.groups, size: 30, color: Colors.white),
          Icon(Icons.chat_bubble, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
      ),
    );
  }
}
