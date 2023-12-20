import 'package:flutter/material.dart';
import 'screens.dart';
import 'ContactScreen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final List _screens = [
    const HomeScreen(),
    const PremiumScreen(),
    OrderHistory(),
    const ContactUsPage(),

  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
   return Scaffold(
  body: _screens[_currentIndex],
  bottomNavigationBar: Container(
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 0,
          blurRadius: 10,
        ),
      ],
    ),
    child: BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color.fromARGB(255, 55, 16, 132),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: const Color.fromARGB(255, 55, 16, 132),
      unselectedItemColor: Colors.grey,
      elevation: 0.0,
      
      items: [
        Icons.home,
        Icons.card_giftcard_rounded,
        Icons.receipt,
        Icons.live_help
      ]
          .asMap()
          .map((key, value) => MapEntry(
                key,
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 3.0,
                      horizontal: 19.0,
                    ),
                    decoration: BoxDecoration(
                      color: _currentIndex == key
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Icon(value),
                  ),
                  label: '',
                ),
              ))
          .values
          .toList(),
    ),
  ),
);

  }
}