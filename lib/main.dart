// pubspec.yaml dependencies
/*
dependencies:
  flutter:
    sdk: flutter
  mailer: ^6.0.1
  shared_preferences: ^2.2.2
  file_picker: ^6.1.1
*/

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EmailApp());
}

class EmailApp extends StatelessWidget {
  const EmailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
