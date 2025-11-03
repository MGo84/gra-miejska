import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../models/mission.dart';
import '../data/mission_paths.dart';
import '../services/mission_loader.dart';
import '../providers/game_progress_provider.dart';
import '../widgets/game_menu_bar.dart';
import '../core/widgets/game_status_bar.dart';

class MissionRunnerScreen extends StatefulWidget {
  final String missionId;
  const MissionRunnerScreen({super.key, required this.missionId});

  @override
  State<MissionRunnerScreen> createState() => _MissionRunnerScreenState();
}

class _MissionRunnerScreenState extends State<MissionRunnerScreen> {
  Mission? _mission;
  int _index = 0;
  String? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _mission = missionById(widget.missionId);
    if (_mission == null) {
      // Attempt to load from assets if not found in static list
      MissionLoader.loadFromAssets()
          .then((list) {
            Mission? found;
            for (final m in list) {
              if (m.id == widget.missionId) {
                found = m;
                break;
              }
            }
            if (found != null) {
              setState(() {
                _mission = found;
              });
            }
          })
          .catchError((_) {});
    }
  }

  void _next() {
    if (_mission == null) return;
    if (_index < _mission!.steps.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mission == null) {
      // Show loading scaffold but keep top/bottom bars consistent with the
      // rest of the app so navigation looks the same.
      final gp = context.watch<GameProgressProvider>();
      final playerName = gp.progress?.username ?? 'Gracz';
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: GameStatusBar(
            timerSeconds: 0,
            points: gp.progress?.solvedPoints.length ?? 0,
            level: 1,
            hint: 'Ładowanie misji...',
            playerName: playerName,
            missionName: 'Misja',
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ładowanie misji...'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final list = await MissionLoader.loadFromAssets();
                  Mission? found;
                  for (final m in list) {
                    if (m.id == widget.missionId) {
                      found = m;
                      break;
                    }
                  }
                  if (found != null) setState(() => _mission = found);
                },
                child: const Text('Spróbuj załadować z assets'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: GameMenuBar(
          onMenuTap: (id) {
            if (id == 'home') Navigator.pushReplacementNamed(context, '/home');
            if (id == 'map') Navigator.pushReplacementNamed(context, '/map');
            if (id == 'ekwipunek')
              Navigator.pushReplacementNamed(context, '/inventory');
            if (id == 'powrot') {
              final provider = context.read<GameProgressProvider>();
              final route = provider.progress?.currentScreen ?? '/intro';
              final args = provider.progress?.currentArgs;
              Navigator.pushNamed(context, route, arguments: args);
            }
          },
          active: 'map',
        ),
      );
    }

    final step = _mission!.steps[_index];

    final gp = context.watch<GameProgressProvider>();
    final playerName = gp.progress?.username ?? 'Gracz';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: GameStatusBar(
          timerSeconds: 0,
          points: gp.progress?.solvedPoints.length ?? 0,
          level: 1,
          hint: '',
          playerName: playerName,
          missionName: tr(_mission!.titleKey),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: step.type == MissionStepType.text
                    ? Text(tr(step.contentKey), textAlign: TextAlign.justify)
                    : _buildQuestion(step),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _answered || step.type == MissionStepType.text
                  ? _next
                  : null,
              child: Text(
                _index < _mission!.steps.length - 1 ? 'Dalej' : 'Zakończ',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: GameMenuBar(
        onMenuTap: (id) {
          if (id == 'home') Navigator.pushReplacementNamed(context, '/home');
          if (id == 'map') Navigator.pushReplacementNamed(context, '/map');
          if (id == 'ekwipunek')
            Navigator.pushReplacementNamed(context, '/inventory');
          if (id == 'powrot') {
            final provider = context.read<GameProgressProvider>();
            final route = provider.progress?.currentScreen ?? '/intro';
            final args = provider.progress?.currentArgs;
            Navigator.pushNamed(context, route, arguments: args);
          }
        },
        active: 'map',
      ),
    );
  }

  Widget _buildQuestion(MissionStep step) {
    final options = step.options ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tr(step.contentKey),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...options.entries.map((e) {
          final key = e.key;
          final label = tr(e.value);
          final isSelected = _selected == key;
          Color? bg;
          if (_answered) {
            if (key == step.correctOption)
              bg = Colors.green[700];
            else if (isSelected)
              bg = Colors.red[700];
            else
              bg = null;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: bg),
              onPressed: _answered
                  ? null
                  : () {
                      setState(() {
                        _selected = key;
                        _answered = true;
                      });
                    },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('$key) $label'),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
