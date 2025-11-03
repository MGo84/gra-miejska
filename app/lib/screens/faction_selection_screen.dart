import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_progress_provider.dart';
import '../models/game_progress.dart';

class FactionSelectionScreen extends StatelessWidget {
  const FactionSelectionScreen({Key? key}) : super(key: key);

  void _choose(BuildContext context, String faction) {
    // Save chosen faction as current place and open map with faction arg
    final provider = context.read<GameProgressProvider>();
    final progress = GameProgress(
      currentScreen: '/map',
      currentArgs: {'faction': faction},
      solvedPoints: provider.progress?.solvedPoints ?? [],
      inventory: provider.progress?.inventory ?? [],
      username: provider.progress?.username,
    );
    provider.save(progress).then((_) {
      Navigator.pushReplacementNamed(
        context,
        '/map',
        arguments: {'faction': faction},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wybierz stronę'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Za kogo chcesz grać?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _choose(context, 'ludzie'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('Wybierz ludzi'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _choose(context, 'ciemnosc'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('Wybierz siły ciemności'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Po wyborze zobaczysz mapę z misjami dostosowaną do wybranej strony.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
