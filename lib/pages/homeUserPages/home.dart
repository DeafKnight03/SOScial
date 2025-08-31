import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Benvenuto nella Home!',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
