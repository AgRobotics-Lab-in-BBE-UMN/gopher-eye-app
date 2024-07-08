import 'package:flutter/material.dart';
import 'package:gopher_eye/screens/main_screen.dart';

class BottomNavigationBarModel extends StatefulWidget {
  const BottomNavigationBarModel({super.key});

  @override
  State<StatefulWidget> createState() => _BottomNavigationBarModel();
}

class _BottomNavigationBarModel extends State<StatefulWidget> {
  int constIndex = 0;
  final List<Widget> screens = [
    const MainScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: screens[constIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.green,
          showUnselectedLabels: false,
          onTap: (index) {
            setState(() {
              constIndex = index;
            });
          },
          currentIndex: constIndex,
          items: const [
            BottomNavigationBarItem(
              tooltip: "Your Crops",
              icon: Icon(Icons.grass),
              label: 'Your crops',
            ),
            BottomNavigationBarItem(
              tooltip: "Chat Support",
              icon: Icon(Icons.forum),
              label: 'Chat Support',
            ),
            BottomNavigationBarItem(
              tooltip: "Your Profile",
              icon: Icon(Icons.person),
              label: 'You',
            ),
          ],
        ));
  }
}
