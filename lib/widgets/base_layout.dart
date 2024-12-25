import 'dart:ui';
import 'package:auth_firebase/widgets/song/player_interface.dart';
import 'package:auth_firebase/providers/audio_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseLayout extends StatefulWidget {
  final Widget child;
  final ValueChanged<int>? onIndexChanged;

  const BaseLayout({
    Key? key,
    required this.child,
    this.onIndexChanged,
  }) : super(key: key);

  @override
  _BaseLayoutState createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    // Only navigate if the selected index changes
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/search');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/library');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }

      // Notify the parent widget about the index change
      if (widget.onIndexChanged != null) {
        widget.onIndexChanged!(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the AudioProvider using Provider.of
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);

    // Set background color based on the selected index
    Color backgroundColor;
    if (_selectedIndex == 2) {
      backgroundColor = Colors.white; // Library
    } else {
      backgroundColor = Colors.black.withOpacity(0.8); // Other tabs
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: widget.child,
          ),
          PlayerInterface(
            audioProvider: audioProvider,
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            backgroundColor: Colors.black.withOpacity(0.8),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
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
