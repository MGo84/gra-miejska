import 'package:flutter/material.dart';
import '../core/widgets/game_status_bar.dart';
import 'package:provider/provider.dart';
import '../providers/game_progress_provider.dart';
import '../widgets/game_menu_bar.dart';

import '../models/game_progress.dart';

class ChoiceGameScreen extends StatefulWidget {
  const ChoiceGameScreen({super.key});

  @override
  State<ChoiceGameScreen> createState() => _ChoiceGameScreenState();
}

class _ChoiceGameScreenState extends State<ChoiceGameScreen> {
  int? _selectedIndex;
  String _feedback = '';

  final List<String> _options = [
    'A: Podejść do drzwi i zapukać.',
    'B: Obejść budynek i poszukać tylnego wejścia.',
    'C: Zadzwonić na numer znaleziony wcześniej.',
    'D: Poczekać i obserwować okolicę.',
  ];

  void _select(int index) async {
    setState(() {
      _selectedIndex = index;
      _feedback = index == 0
          ? 'Wybrałeś A — drzwi otwarte, historia idzie w stronę konfrontacji.'
          : index == 1
          ? 'Wybrałeś B — znajdujesz sekretne wejście.'
          : index == 2
          ? 'Wybrałeś C — nikt nie odbiera, ale pozostawia trop.'
          : 'Wybrałeś D — czas mija, obserwujesz ciekawą interakcję.';
    });

    // Save minimal progress so resume can return here
    final provider = context.read<GameProgressProvider>();
    final progress = GameProgress(
      currentScreen: '/choice',
      solvedPoints: provider.progress?.solvedPoints ?? [],
      inventory: provider.progress?.inventory ?? [],
      username: provider.progress?.username,
    );
    await provider.save(progress);
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProgressProvider>();
    final playerName = gp.progress?.username ?? 'Zalogowany';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: GameStatusBar(
          timerSeconds: 0,
          points: 23,
          level: 2,
          hint: 'Podpowiedź',
          playerName: playerName,
          missionName: 'Decyzja',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Decyzja',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'W tym momencie możesz wybrać jedną z czterech opcji. Wpływa to na przebieg historii.',
            ),
            const SizedBox(height: 20),
            ..._options.asMap().entries.map((e) {
              final idx = e.key;
              final text = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedIndex == idx
                        ? Colors.deepPurple
                        : null,
                  ),
                  onPressed: () => _select(idx),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(text),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            if (_feedback.isNotEmpty)
              Text(
                _feedback,
                style: const TextStyle(fontSize: 16, color: Colors.amber),
              ),
          ],
        ),
      ),
      bottomNavigationBar: GameMenuBar(
        onMenuTap: (id) {
          if (id == 'home') Navigator.pushReplacementNamed(context, '/home');
          if (id == 'map') Navigator.pushReplacementNamed(context, '/map');
          if (id == 'ekwipunek') {
            Navigator.pushReplacementNamed(context, '/choice');
          }
          if (id == 'powrot') {
            final provider = context.read<GameProgressProvider>();
            final route = provider.progress?.currentScreen ?? '/intro';
            final args = provider.progress?.currentArgs;
            Navigator.pushNamed(context, route, arguments: args);
          }
        },
        active: 'ekwipunek',
      ),
    );
  }
}
