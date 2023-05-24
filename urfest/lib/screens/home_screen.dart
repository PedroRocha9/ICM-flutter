import 'package:flutter/material.dart';
import 'package:urfest/screens/findbuddy.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    //LineUpPage(),
    FindBuddyPage(),
    //QRCodePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType
            .fixed, // to show all the items in the bottom bar
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.library_music_outlined), label: 'Line Up'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Find Buddy',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR Code'),
        ],
      ),
    );
  }
}
