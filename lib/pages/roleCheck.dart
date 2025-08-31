import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'homeUser.dart';
import 'homeAdmin.dart';

class RoleCheck extends StatelessWidget {
  const RoleCheck({super.key});
  @override
  Widget build(BuildContext context) {
    
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // Controlla il ruolo dell'utente nel database Firestore
      return StreamBuilder<DocumentSnapshot?>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          var s = snapshot.data!.data() as Map<String, dynamic>;
          bool checkAdmin = s['isAdmin'] == true;
          
          if (checkAdmin) {
            return const HomeAdmin();
          }
          return const HomeUser();
        },
      );
  }
}

