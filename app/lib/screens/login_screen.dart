import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/local_storage_service.dart';
import '../providers/game_progress_provider.dart';
import '../models/game_progress.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    final storedUser = await LocalStorageService.getUser();
    _emailController.text = storedUser['email'] ?? '';
    _passwordController.text = ''; // hasło czyszczone
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final storedUser = await LocalStorageService.getUser();

      if (storedUser['email'] == email && storedUser['password'] == password) {
        await LocalStorageService.setLoggedIn(true);
        // Remember last user and update global progress username
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_user', email);
        try {
          final provider = context.read<GameProgressProvider>();
          final existing = provider.progress;
          final progress = GameProgress(
            currentScreen: existing?.currentScreen ?? '/home',
            currentArgs: existing?.currentArgs,
            solvedPoints: existing?.solvedPoints ?? [],
            inventory: existing?.inventory ?? [],
            username: email,
          );
          await provider.save(progress);
        } catch (_) {}
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('login.error'.tr())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: AppBar(title: Text('login.button'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'login.email'.tr()),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'login.email'.tr()
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'login.password'.tr()),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'login.password'.tr()
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: Text('login.button'.tr()),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: Text('login.no_account'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
