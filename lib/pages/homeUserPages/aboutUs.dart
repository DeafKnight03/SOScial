import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Benvenuto nella pagina About Us!',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
