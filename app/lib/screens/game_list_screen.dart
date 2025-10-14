import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/game.dart';
import '../data/mock_games.dart';
import 'game_detail_screen.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  List<Game> games = [];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    final box = Hive.box('games');

    if (box.isEmpty) {
      // zapis mock danych do Hive (pierwsze uruchomienie)
      for (var game in mockGames) {
        await box.put(game.id, game.toMap());
      }
    }

    // wczytaj gry z Hive
    final loadedGames = box.values.map((e) => Game.fromMap(Map<String, dynamic>.from(e))).toList();

    setState(() {
      games = loadedGames;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('games.list'.tr())),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(game.name),
              subtitle: Text(
                '${game.description}\n'
                '${'games.duration'.tr(namedArgs: {'min': game.durationMinutes.toString()})} | '
                '${'games.points'.tr(namedArgs: {'points': game.points.toString()})}'
              ),
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GameDetailScreen(game: game)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
