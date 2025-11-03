import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_progress.dart';

class GameProgressStorage {
  static const _key = 'game_progress';

  static Future<void> save(GameProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, progress.toRawJson());
  }

  static Future<GameProgress?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return GameProgress.fromRawJson(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
