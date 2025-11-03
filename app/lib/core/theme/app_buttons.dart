import 'package:flutter/material.dart';

class AppButtonStyles {
  static final ElevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      fontFamily: 'Roboto',
    ),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  );
}
