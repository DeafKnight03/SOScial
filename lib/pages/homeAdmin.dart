import 'package:flutter/material.dart';
import 'homeAdminPages/welcome.dart';
import 'homeAdminPages/manageSignals.dart';
import 'homeAdminPages/map.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int currentIndex = 0;
  final List<Widget> _pages = const [Welcome(), ManageSignals(), Map()];
  @override
  Widget build(BuildContext context) {
    //final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Color.fromRGBO(195, 241, 243, 1),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: currentIndex,
        selectedItemColor: Color.fromRGBO(131, 197, 190, 1),
        unselectedItemColor: Color.fromRGBO(214, 236, 243, 1),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color.fromRGBO(0, 109, 119, 1),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.crisis_alert_rounded),
            label: 'Gestione Segnalazioni',
            backgroundColor: Color.fromRGBO(0, 109, 119, 1),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mappa',
            backgroundColor: Color.fromRGBO(0, 109, 119, 1),
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
