import 'package:flutter/material.dart';
import '../core/widgets/game_status_bar.dart';
import 'package:provider/provider.dart';
import '../providers/game_progress_provider.dart';
import '../widgets/game_menu_bar.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);

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
              missionName: 'Ekwipunek',
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Text(
              'Ekwipunek',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('Tu wyświetli się Twoje ekwipunek i znalezione przedmioty.'),
          ],
        ),
      ),
      bottomNavigationBar: GameMenuBar(
        onMenuTap: (id) {
          if (id == 'home') Navigator.pushReplacementNamed(context, '/home');
          if (id == 'map') Navigator.pushReplacementNamed(context, '/map');
          if (id == 'ekwipunek') return;
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
