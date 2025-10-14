import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/local_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final storedUser = await LocalStorageService.getUser();
    setState(() {
      userEmail = storedUser['email'] ?? 'Użytkownik';
    });
  }

  Future<void> _logout() async {
    await LocalStorageService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home.welcome'.tr(namedArgs: {'user': userEmail})),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Text(
                'home.welcome'.tr(namedArgs: {'user': userEmail}),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/games');
              },
              child: Text('games.list'.tr()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _logout,
              child: Text('login.button'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
