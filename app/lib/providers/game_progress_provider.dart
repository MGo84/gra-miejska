import 'package:flutter/material.dart';
import '../models/game_progress.dart';
import '../services/game_progress_storage.dart';

class GameProgressProvider extends ChangeNotifier {
  GameProgress? _progress;
  bool _loading = true;

  GameProgress? get progress => _progress;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _progress = await GameProgressStorage.load();
    _loading = false;
    notifyListeners();
  }

  Future<void> save(GameProgress progress) async {
    _progress = progress;
    await GameProgressStorage.save(progress);
    notifyListeners();
  }

  Future<void> clear() async {
    _progress = null;
    await GameProgressStorage.clear();
    notifyListeners();
  }
}
