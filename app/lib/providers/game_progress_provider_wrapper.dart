import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_progress_provider.dart';

class GameProgressProviderWrapper extends StatelessWidget {
  final Widget child;
  const GameProgressProviderWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProgressProvider()..load(),
      child: child,
    );
  }
}
