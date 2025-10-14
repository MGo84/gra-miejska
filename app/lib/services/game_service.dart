import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/game_point.dart';

class GameService {
  static Future<List<GamePoint>> loadGamePoints() async {
    final data = await rootBundle.loadString('assets/data/game_points.json');
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((e) => GamePoint.fromJson(e)).toList();
  }
}
