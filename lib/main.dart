import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';

import 'pages/login_signup.dart';
import 'pages/roleCheck.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCtHyqgbk-INGuAilEr_nZg4BxDYo5hMKY",
        authDomain: "my-app-43fcf.firebaseapp.com",
        projectId: "my-app-43fcf",
        storageBucket: "my-app-43fcf.firebasestorage.app",
        messagingSenderId: "1085359842942",
        appId: "1:1085359842942:web:36829c9d3a3611fe73da2f",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.sairaTextTheme(Theme.of(context).textTheme),
      ),
      //theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data!.emailVerified) {
            return const RoleCheck();
          }
          return const Login();
        },
      ),
    );
  }
}
