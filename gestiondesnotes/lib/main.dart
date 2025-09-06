import 'package:flutter/material.dart';
import 'interfaces/connexion.dart';

void main() {
  runApp(const MonApplication());
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mes Notes',
      theme: ThemeData(
        primaryColor: const Color(0xFF002060),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const Connexion(),
      debugShowCheckedModeBanner: false,
    );
  }
}