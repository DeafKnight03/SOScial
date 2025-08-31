import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import 'homeUserPages/aboutUs.dart';
import 'homeUserPages/home.dart';
import 'homeUserPages/mapPage.dart'; 
import 'homeUserPages/account.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  final List<Widget> _pages = const [
    Home(),
    Account(),
    AboutUs(),
    MapPage(),
  ];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    //final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 208, 176),
      bottomNavigationBar: BottomNavigationBar(
    currentIndex: currentIndex,
    selectedItemColor: Color.fromRGBO(185, 36, 6, 1),
    unselectedItemColor: Color.fromRGBO(255, 168, 150, 1.0),
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
        backgroundColor: Color.fromRGBO(56, 0, 10, 1.0),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profilo',
        backgroundColor: Color.fromRGBO(56, 0, 10, 1.0),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.info),
        label: 'About Us',
        backgroundColor: Color.fromRGBO(56, 0, 10, 1.0),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.map),
        
        label: 'Mappa',
        backgroundColor: Color.fromRGBO(56, 0, 10, 1.0),
      ),
    ],
    onTap: (index) {
      setState(() {
        currentIndex = index;
      });
    },
  ),
      body: _pages[currentIndex],

    );
  }
}
