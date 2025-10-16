import 'package:flutter/material.dart';
import '../models/game_point.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String feedback = '';

  @override
  Widget build(BuildContext context) {
    final GamePoint point = ModalRoute.of(context)!.settings.arguments as GamePoint;

    return Scaffold(
      appBar: AppBar(title: Text(point.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(point.question, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            if (point.type == 'quiz') ..._buildQuiz(point),
            if (point.type == 'text') ..._buildText(point),
            const SizedBox(height: 24),
              Text(feedback, style: const TextStyle(fontSize: 18, color: Colors.blue))
          ],
        ),
      ),
    );
  }

  List<Widget> _buildQuiz(GamePoint point) {
    return point.answers!
        .asMap()
        .entries
        .map((entry) => ElevatedButton(
              onPressed: () {
                setState(() {
                  feedback = entry.key == point.correct ? '✅ Poprawna odpowiedź!' : '❌ Spróbuj ponownie.';
                });
              },
              child: Text(entry.value),
            ))
        .toList();
  }

  List<Widget> _buildText(GamePoint point) {
    final controller = TextEditingController();
    return [
      TextField(controller: controller, decoration: const InputDecoration(labelText: 'Twoja odpowiedź')),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: () {
          setState(() {
            feedback = controller.text.trim().toLowerCase() == point.correctText!.toLowerCase()
                ? '✅ Dobrze!'
                : '❌ Niepoprawnie.';
          });
        },
        child: const Text('Sprawdź'),
      )
    ];
  }
}
