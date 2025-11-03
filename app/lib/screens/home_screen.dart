import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/game_progress_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_user');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<GameProgressProvider>();
    final progress = progressProvider.progress;
    final prefs = SharedPreferences.getInstance();
    return FutureBuilder<SharedPreferences>(
      future: prefs,
      builder: (context, snapshot) {
        final user =
            (snapshot.hasData &&
                (snapshot.data!.getString('last_user') != null) &&
                (snapshot.data!.getString('last_user')!.isNotEmpty))
            ? snapshot.data!.getString('last_user')!
            : 'Użytkownik';
        return Scaffold(
          appBar: AppBar(
            title: Text('home.welcome'.tr(namedArgs: {'user': user})),
            actions: [
              PopupMenuButton<Locale>(
                icon: const Icon(Icons.language),
                tooltip: 'Zmień język',
                onSelected: (locale) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('locale_code', locale.languageCode);
                  await context.setLocale(locale);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: const Locale('pl'),
                    child: const Text('POLSKI'),
                  ),
                  PopupMenuItem(
                    value: const Locale('en'),
                    child: const Text('ENGLISH'),
                  ),
                  PopupMenuItem(
                    value: const Locale('de'),
                    child: const Text('DEUTSCH'),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Ustawienia',
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Wyloguj',
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('last_user');
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'home.welcome'.tr(namedArgs: {'user': user}),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/intro');
                    },
                    child: Text('games.start'.tr().toUpperCase()),
                  ),
                  const SizedBox(height: 12),
                  if (progress != null)
                    ElevatedButton(
                      onPressed: () {
                        final route = progress.currentScreen.isNotEmpty
                            ? progress.currentScreen
                            : '/intro';
                        final args = progress.currentArgs;
                        Navigator.pushNamed(context, route, arguments: args);
                      },
                      child: Text('games.resume'.tr().toUpperCase()),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
