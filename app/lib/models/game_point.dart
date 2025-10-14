class GamePoint {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final String type; // quiz / text
  final String question;
  final List<String>? answers;
  final int? correct;
  final String? correctText;

  GamePoint({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    required this.question,
    this.answers,
    this.correct,
    this.correctText,
  });

  factory GamePoint.fromJson(Map<String, dynamic> json) {
    return GamePoint(
      id: json['id'],
      name: json['name'],
      lat: json['lat'],
      lng: json['lng'],
      type: json['type'],
      question: json['question'],
      answers: json['answers'] != null ? List<String>.from(json['answers']) : null,
      correct: json['correct'],
      correctText: json['correct_text'],
    );
  }
}
