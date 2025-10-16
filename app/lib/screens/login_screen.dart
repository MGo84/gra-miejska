import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/local_storage_service.dart';

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
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('login.error'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'login.email'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'login.password'.tr()),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'login.password'.tr() : null,
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
