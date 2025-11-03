// Simple mission model used to describe a sequence of "boards" (steps)
// Each step can be a text screen or a question screen with multiple choices.

enum MissionStepType { text, question }

class MissionStep {
  final String id; // unique within mission, e.g. "a1_tekst1" or "a1_pytanie1"
  final MissionStepType type;
  final String contentKey; // localization key or raw text id (e.g. "a1_tekst1")

  // Question-specific fields
  final Map<String, String>? options; // key=A/B/C/D -> localization key
  final String? correctOption; // key of the correct option, e.g. 'A'

  const MissionStep({
    required this.id,
    required this.type,
    required this.contentKey,
    this.options,
    this.correctOption,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'contentKey': contentKey,
    if (options != null) 'options': options,
    if (correctOption != null) 'correctOption': correctOption,
  };

  factory MissionStep.fromJson(Map<String, dynamic> j) {
    final typeStr = (j['type'] ?? 'text') as String;
    return MissionStep(
      id: j['id'] as String,
      type: MissionStepType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => MissionStepType.text,
      ),
      contentKey: j['contentKey'] as String,
      options: j['options'] != null
          ? Map<String, String>.from(j['options'] as Map)
          : null,
      correctOption: j['correctOption'] as String?,
    );
  }
}

class Mission {
  final String id; // e.g. 'a1'
  final String titleKey; // localization key for mission title
  final List<MissionStep> steps;

  const Mission({
    required this.id,
    required this.titleKey,
    required this.steps,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titleKey': titleKey,
    'steps': steps.map((s) => s.toJson()).toList(),
  };

  factory Mission.fromJson(Map<String, dynamic> j) => Mission(
    id: j['id'] as String,
    titleKey: j['titleKey'] as String,
    steps: (j['steps'] as List)
        .map((e) => MissionStep.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}
