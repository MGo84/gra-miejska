class Game {
  final String id;
  final String name;
  final String description;
  final int durationMinutes;
  final int points;

  Game({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.points,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'durationMinutes': durationMinutes,
      'points': points,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      durationMinutes: map['durationMinutes'],
      points: map['points'],
    );
  }
}
