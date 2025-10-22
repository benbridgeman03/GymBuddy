import 'package:cloud_firestore/cloud_firestore.dart';
import 'set_type.dart';

//One set of an exercise
class WorkoutSetLog {
  final int setIndex;
  final int reps;
  final double weight; // can be 0 for bodyweight
  final int restSeconds;
  final SetType setType;

  WorkoutSetLog({
    required this.setIndex,
    required this.reps,
    required this.weight,
    required this.restSeconds,
    required this.setType,
  });

  Map<String, dynamic> toMap() => {
    'setIndex': setIndex,
    'reps': reps,
    'weight': weight,
    'restSeconds': restSeconds,
    'setType': setType.name,
  };

  factory WorkoutSetLog.fromMap(Map<String, dynamic> data) => WorkoutSetLog(
    setIndex: data['setIndex'],
    reps: data['reps'],
    weight: (data['weight'] as num).toDouble(),
    restSeconds: data['restSeconds'],
    setType: SetType.values.firstWhere((e) => e.name == data['setType']),
  );
}

//One exercise in a workout session
class WorkoutExerciseLog {
  final String exerciseId;
  final String name;
  final List<WorkoutSetLog> sets;

  WorkoutExerciseLog({
    required this.exerciseId,
    required this.name,
    required this.sets,
  });

  Map<String, dynamic> toMap() => {
    'exerciseId': exerciseId,
    'name': name,
    'sets': sets.map((s) => s.toMap()).toList(),
  };

  factory WorkoutExerciseLog.fromMap(Map<String, dynamic> data) =>
      WorkoutExerciseLog(
        exerciseId: data['exerciseId'],
        name: data['name'],
        sets: (data['sets'] as List<dynamic>)
            .map((s) => WorkoutSetLog.fromMap(s))
            .toList(),
      );
}

//One full workout session log
class WorkoutSession {
  final String id;
  final String templateId; // link back to template
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<WorkoutExerciseLog> exercises;

  WorkoutSession({
    required this.id,
    required this.templateId,
    required this.startedAt,
    this.completedAt,
    required this.exercises,
  });

  Map<String, dynamic> toMap() => {
    'templateId': templateId,
    'startedAt': Timestamp.fromDate(startedAt),
    'completedAt': completedAt != null
        ? Timestamp.fromDate(completedAt!)
        : null,
    'exercises': exercises.map((e) => e.toMap()).toList(),
  };

  factory WorkoutSession.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutSession(
      id: doc.id,
      templateId: data['templateId'],
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      exercises: (data['exercises'] as List<dynamic>)
          .map((e) => WorkoutExerciseLog.fromMap(e))
          .toList(),
    );
  }
}
