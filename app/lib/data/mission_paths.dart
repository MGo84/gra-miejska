import '../models/mission.dart';

// Example mission paths file.
// Add new missions here and define their ordered steps.

final List<Mission> missions = [
  Mission(
    id: 'a1',
    titleKey: 'missions.a1.title',
    steps: const [
      MissionStep(
        id: 'a1_tekst1',
        type: MissionStepType.text,
        contentKey: 'a1_tekst1',
      ),
      MissionStep(
        id: 'a1_pytanie1',
        type: MissionStepType.question,
        contentKey: 'a1_pytanie1',
        options: {
          'A': 'a1_odpowiedz_a1',
          'B': 'a1_odpowiedz_b1',
          'C': 'a1_odpowiedz_c1',
          'D': 'a1_odpowiedz_d1',
        },
        correctOption: 'A',
      ),
      MissionStep(
        id: 'a1_tekst2',
        type: MissionStepType.text,
        contentKey: 'a1_tekst2',
      ),
    ],
  ),

  // Add more missions below. Example:
  // Mission(id: 'b1', titleKey: 'missions.b1.title', steps: [ ... ])
];

// Utility: lookup a mission by id
Mission? missionById(String id) {
  for (final m in missions) {
    if (m.id == id) return m;
  }
  return null;
}
