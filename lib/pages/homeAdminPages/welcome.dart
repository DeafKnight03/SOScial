import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Benvenuto nel Pannello di Amministrazione!',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
