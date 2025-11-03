import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';
import '../providers/game_progress_provider.dart';
import '../models/game_progress.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _usernameController;
  String? _storedLoginHint;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _loadInitialValues();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialValues() async {
    final gp = context.read<GameProgressProvider>();
    final stored = await LocalStorageService.getUser();
    final prefs = await SharedPreferences.getInstance();
    final displayName = prefs.getString('display_name');

    setState(() {
      _storedLoginHint = stored['email'];
      _usernameController.text = displayName ?? gp.progress?.username ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final gp = context.watch<GameProgressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Tryb narracji'),
              subtitle: const Text('Włącz/wyłącz narrację (overlay)'),
              value: settings.narrationEnabled,
              onChanged: (v) => settings.setNarrationEnabled(v),
            ),
            const SizedBox(height: 12),
            Text(
              'Nazwa gracza',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nazwa gracza',
                hintText: _storedLoginHint != null
                    ? 'Aktualny login: $_storedLoginHint'
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final newName = _usernameController.text.trim();
                final prefs = await SharedPreferences.getInstance();
                // Save display name separately from login credentials
                await prefs.setString('display_name', newName);
                try {
                  final existing = gp.progress;
                  final updated = GameProgress(
                    currentScreen: existing?.currentScreen ?? '/home',
                    currentArgs: existing?.currentArgs,
                    solvedPoints: existing?.solvedPoints ?? [],
                    inventory: existing?.inventory ?? [],
                    username: newName,
                  );
                  final provider = context.read<GameProgressProvider>();
                  await provider.save(updated);
                } catch (_) {}
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Zapisano nazwę gracza')),
                );
              },
              child: const Text('Zapisz nazwę'),
            ),
            const SizedBox(height: 12),
            Text(
              'Inne ustawienia (w przyszłości)...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
