import 'dart:convert';

class GameProgress {
  final String currentScreen; // e.g. '/map', '/intro', etc.
  final Map<String, dynamic>? currentArgs; // optional route arguments
  final List<String> solvedPoints; // e.g. ['Plac Grunwaldzki']
  final List<String> inventory; // e.g. ['klucz', 'notatka']
  final String? username;

  GameProgress({
    required this.currentScreen,
    this.currentArgs,
    required this.solvedPoints,
    required this.inventory,
    this.username,
  });

  Map<String, dynamic> toJson() => {
    'currentScreen': currentScreen,
    'currentArgs': currentArgs,
    'solvedPoints': solvedPoints,
    'inventory': inventory,
    'username': username,
  };

  factory GameProgress.fromJson(Map<String, dynamic> json) => GameProgress(
    currentScreen: json['currentScreen'] as String? ?? '/intro',
    currentArgs: json['currentArgs'] != null
        ? Map<String, dynamic>.from(json['currentArgs'])
        : null,
    solvedPoints: List<String>.from(json['solvedPoints'] ?? []),
    inventory: List<String>.from(json['inventory'] ?? []),
    username: json['username'] as String?,
  );

  String toRawJson() => jsonEncode(toJson());
  factory GameProgress.fromRawJson(String str) =>
      GameProgress.fromJson(jsonDecode(str));
}
