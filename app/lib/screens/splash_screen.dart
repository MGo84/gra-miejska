import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ⏳ Po 5 sekundach przejście na ekran logowania
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        // Use a non-animated replacement to avoid transient white frames
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fiolotowe tło
      backgroundColor: Colors.deepPurple,
      body: Container(
        width: double.infinity,
        color: Colors.deepPurple,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // console/terminal icon
            const Icon(Icons.terminal, size: 120, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'Gra Miejska',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'console',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
