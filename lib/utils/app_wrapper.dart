import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_firebase/widgets/song/player_interface.dart';
import 'package:auth_firebase/providers/audio_provider.dart';
import 'package:auth_firebase/screens/home_screen.dart';
import 'package:auth_firebase/screens/search/search_screen.dart';
import 'package:auth_firebase/screens/playlist/playlist_screen.dart';
import 'package:auth_firebase/screens/profile/profile_screen.dart';

class AppWrapper extends StatefulWidget {
  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Access the AudioProvider
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);

    // List of screens
    final List<Widget> pages = [
      HomeScreen(),
      SearchScreen(),
      PlaylistScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
          ),
          PlayerInterface(audioProvider: audioProvider), // Player at the bottom
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            backgroundColor: Colors.black.withOpacity(0.8),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 35),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search, size: 35),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music, size: 35),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 35),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
