import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/pages/roleCheck.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isRegister = false;
  String message = "Inserisci le tue credenziali per accedere";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _doStuff() async {
    if (isRegister) {
      try {
        var user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.user!.uid)
            .set({'isAdmin': false});
        setState(() {
          message = "Credenziali create con successo! Ora puoi accedere.";
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          message = "Errore durante la registrazione: ${e.message}";
        });
      }
    } else {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        setState(() {});
      } on FirebaseAuthException catch (e) {
        setState(() {
          message = "Credenziali non valide";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null &&
        !FirebaseAuth.instance.currentUser!.emailVerified) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Verifica la tua email prima di procedere",
                  style: GoogleFonts.prozaLibre(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.currentUser!
                        .sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Email di verifica inviata! Controlla la tua casella di posta.",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.email_outlined),
                  label: const Text("Invia email di verifica"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    FirebaseAuth.instance.currentUser!.reload();
                    setState(() {});
                  },
                  child: const Text("Ho verificato la mail"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser!.emailVerified) {
      return const RoleCheck();
    }

    String title = isRegister ? "Registrazione" : "Login";
    String buttonText = isRegister ? "Registrati" : "Login";

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    message,
                    style: GoogleFonts.prozaLibre(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _doStuff,
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        message = isRegister
                            ? "Inserisci le tue credenziali per accedere"
                            : "Inserisci i tuoi dati per registrarti";
                        isRegister = !isRegister;
                      });
                    },
                    child: Text(
                      isRegister
                          ? 'Hai già un account? Accedi'
                          : 'Non hai un account? Registrati',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
