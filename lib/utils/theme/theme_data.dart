import 'package:flutter/material.dart';

ThemeData buildPurpleTheme() {
  return ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.purple,
    primaryColor: Colors.purple[700],
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: const AppBarTheme(
      toolbarHeight: 80,
      backgroundColor: Colors.purple,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        iconColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            return Colors.purple[600];
          },
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.purple[200]!.withOpacity(0.3);
            }
            return null;
          },
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
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
