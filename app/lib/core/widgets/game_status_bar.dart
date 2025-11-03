import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_progress_provider.dart';

class GameStatusBar extends StatelessWidget {
  final int timerSeconds;
  final int points;
  final int level;
  final String hint;
  final String? playerName;
  final String missionName;

  const GameStatusBar({
    super.key,
    required this.timerSeconds,
    required this.points,
    required this.level,
    required this.hint,
    this.playerName,
    required this.missionName,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = (playerName != null && playerName!.isNotEmpty)
        ? playerName!
        : context.watch<GameProgressProvider>().progress?.username ?? 'Gracz';
    return SafeArea(
      child: Container(
        color: const Color(0xFF232323),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      missionName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                // Left: hint area
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb, color: Colors.yellow, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            hint,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center: timer (visible only when > 0)
                Expanded(
                  child: Center(
                    child: timerSeconds > 0
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer, color: Colors.white, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                _formatTime(timerSeconds),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),

                // Right: points and level
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          points.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.layers, color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'L$level',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
