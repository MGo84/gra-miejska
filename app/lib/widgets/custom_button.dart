import 'package:flutter/material.dart';

/// A small reusable button used across the app. Kept minimal per request
/// (no styling changes) — it simply wraps [ElevatedButton].
class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const CustomButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: child);
  }
}
