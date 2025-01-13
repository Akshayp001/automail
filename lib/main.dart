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
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EmailApp());
}

class EmailApp extends StatelessWidget {
  const EmailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AutoMail',
      theme: buildPurpleTheme(),
      home: const HomeScreen(),
    );
  }
}

ThemeData buildPurpleTheme() {
  return ThemeData(
    useMaterial3: true,

    primarySwatch: Colors.purple, // Overall primary color scheme
    primaryColor: Colors.purple[700], // Specific primary color
    scaffoldBackgroundColor: Colors.grey[100], // Light background for scaffolds
    appBarTheme: const AppBarTheme(
      toolbarHeight: 80,
      backgroundColor: Colors.purple,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white), // Color of app bar icons
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 16,
        ), // Text size for buttons
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 24), // Padding around text
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        elevation: 4, // Add a subtle shadow
      ).copyWith(
        // Customize the background gradient
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            // if (states.contains(MaterialState.pressed)) {
            return Colors.purple[600]; // Darker purple on press
            // } else if (states.contains(MaterialState.disabled)) {
            //   return Colors.grey[400]; // Greyed out if disabled
            // }
            // return null; // Use the default purple gradient
          },
        ),
        foregroundColor:
            MaterialStateProperty.all<Color>(Colors.white), // Text color
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.purple[200]!.withOpacity(0.3); // Ripple effect
            }
            return null;
          },
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87), // Default text color
      titleLarge: TextStyle(
        color: Colors.purple,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.purple, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.amber),
  );
}
