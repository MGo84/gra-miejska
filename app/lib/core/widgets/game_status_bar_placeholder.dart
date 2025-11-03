import 'package:flutter/material.dart';
import 'game_status_bar.dart';

class GameStatusBarPlaceholder extends StatelessWidget {
  const GameStatusBarPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual game data
    return const GameStatusBar(
      timerSeconds: 123,
      points: 42,
      level: 1,
      hint: 'Podpowiedź',
      missionName: 'Misja Demo',
    );
  }
}
