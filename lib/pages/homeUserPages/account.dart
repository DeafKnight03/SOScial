import 'package:flutter/material.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Benvenuto nella pagina account!',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
