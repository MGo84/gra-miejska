import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/mission.dart';

class MissionLoader {
  /// Load missions from the bundled asset `assets/missions.json`.
  static Future<List<Mission>> loadFromAssets() async {
    final raw = await rootBundle.loadString('assets/missions.json');
    final decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((e) => Mission.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
