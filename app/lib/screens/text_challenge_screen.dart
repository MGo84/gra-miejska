import 'package:flutter/material.dart';
import '../core/widgets/game_status_bar.dart';

import '../widgets/game_menu_bar.dart';
import 'package:provider/provider.dart';
import '../providers/game_progress_provider.dart';
import '../models/game_progress.dart';

class TextChallengeScreen extends StatefulWidget {
  const TextChallengeScreen({Key? key}) : super(key: key);

  @override
  State<TextChallengeScreen> createState() => _TextChallengeScreenState();
}

class _TextChallengeScreenState extends State<TextChallengeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _feedback = '';

  // Example correct answers for the probe
  final List<String> _correctAnswers = ['tajne', '1945', '01.01.1945'];

  Future<void> _checkAnswer() async {
    final input = _controller.text.trim();
    final ok = _correctAnswers.any(
      (a) => a.toLowerCase() == input.toLowerCase(),
    );
    setState(() {
      _feedback = ok
          ? '✅ Poprawne hasło!'
          : '❌ Niepoprawne. Spróbuj jeszcze raz.';
    });

    if (ok) {
      final provider = context.read<GameProgressProvider>();
      final progress = GameProgress(
        currentScreen: '/text_challenge',
        solvedPoints: provider.progress?.solvedPoints ?? [],
        inventory: provider.progress?.inventory ?? [],
        username: provider.progress?.username,
      );
      await provider.save(progress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Builder(
          builder: (context) {
            final gp = context.watch<GameProgressProvider>();
            final playerName = gp.progress?.username ?? 'Zalogowany';
            return GameStatusBar(
              timerSeconds: 0,
              points: 23,
              level: 2,
              hint: 'Podpowiedź',
              playerName: playerName,
              missionName: 'Zagadka',
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Zagadka',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Wpisz hasło lub datę, aby rozwiązać zagadkę.'),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Twoja odpowiedź'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: const Text('Sprawdź'),
            ),
            const SizedBox(height: 12),
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
          if (id == 'ekwipunek') Navigator.pushNamed(context, '/inventory');
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
