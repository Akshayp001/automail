

import 'package:flutter/material.dart';

InputDecoration buildInputDecoration({
  required String labelText,
  String? hintText,
  String? helperText,
  IconData? prefixIcon,
  Widget? suffixIcon,
  bool isDense = false,
  String? errorText,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    helperText: helperText,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
    suffixIcon: suffixIcon,
    isDense: isDense,
    errorText: errorText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Colors.blue, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Colors.red, width: 2.0),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Adjust padding as needed
    labelStyle: const TextStyle(color: Colors.grey),
    hintStyle: const TextStyle(color: Colors.grey),
    helperStyle: const TextStyle(color: Colors.grey),
    errorStyle: const TextStyle(color: Colors.red),
  );
}