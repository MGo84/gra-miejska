import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/game.dart';
import '../../core/widgets/game_status_bar.dart';
import 'package:provider/provider.dart';
import '../providers/game_progress_provider.dart';
import '../models/game_progress.dart';

class GameDetailScreen extends StatelessWidget {
  final Game game;
  const GameDetailScreen({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    // final String title = game.name;
    //    final String description = game.description;
    //    final int duration = game.durationMinutes;
    //   final int points = game.points;

    // W przyszłości dane gry mogą być przekazywane przez argumenty
    final Map<String, dynamic>? game =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String description =
        game?['description'] ??
        'Weź udział w miejskiej przygodzie! Rozwiązuj zagadki, odkrywaj punkty i walcz o najwyższy wynik.';
    final int duration = game?['duration'] ?? 120;
    final int points = game?['points'] ?? 10;

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
          missionName: game?['name'] ?? 'Szczegóły gry',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              game?['name'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'games.duration'.tr(namedArgs: {'min': duration.toString()}),
                ),
                Text(
                  'games.points'.tr(namedArgs: {'points': points.toString()}),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                final provider = context.read<GameProgressProvider>();
                final progress = GameProgress(
                  currentScreen: '/map',
                  currentArgs: {'game': game?['name'] ?? ''},
                  solvedPoints: provider.progress?.solvedPoints ?? [],
                  inventory: provider.progress?.inventory ?? [],
                  username: provider.progress?.username,
                );
                await provider.save(progress);
                Navigator.pushNamed(context, '/map');
              },
              icon: const Icon(Icons.map),
              label: Text('games.map'.tr()),
            ),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text(
                  'Rozpocznij grę',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                onPressed: () {
                  (() async {
                    final provider = context.read<GameProgressProvider>();
                    final progress = GameProgress(
                      currentScreen: '/map',
                      currentArgs: {'game': game?['name'] ?? ''},
                      solvedPoints: provider.progress?.solvedPoints ?? [],
                      inventory: provider.progress?.inventory ?? [],
                      username: provider.progress?.username,
                    );
                    await provider.save(progress);
                    Navigator.pushNamed(context, '/map');
                  })();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
