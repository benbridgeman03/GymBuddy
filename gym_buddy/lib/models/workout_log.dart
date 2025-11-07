import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'set_type.dart';

//One set of an exercise
class WorkoutSetLog {
  final int reps;
  final double weight;
  final int restSeconds;
  final SetType setType;

  WorkoutSetLog({
    required this.reps,
    required this.weight,
    required this.restSeconds,
    required this.setType,
  });

  Map<String, dynamic> toMap() => {
    'reps': reps,
    'weight': weight,
    'restSeconds': restSeconds,
    'setType': setType.name,
  };

  factory WorkoutSetLog.fromMap(Map<String, dynamic> data) => WorkoutSetLog(
    reps: data['reps'],
    weight: (data['weight'] as num).toDouble(),
    restSeconds: data['restSeconds'],
    setType: SetType.values.firstWhere((e) => e.name == data['setType']),
  );
}

//One exercise in a workout session
class WorkoutExerciseLog {
  final Exercise exercise;
  final List<WorkoutSetLog> sets;

  WorkoutExerciseLog({required this.exercise, required this.sets});

  Map<String, dynamic> toMap() => {
    'exercise': exercise.toMap(),
    'sets': sets.map((s) => s.toMap()).toList(),
  };

  factory WorkoutExerciseLog.fromMap(Map<String, dynamic> data) =>
      WorkoutExerciseLog(
        exercise: Exercise.fromMap(data['exercise'] as Map<String, dynamic>),
        sets: (data['sets'] as List<dynamic>)
            .map((s) => WorkoutSetLog.fromMap(s))
            .toList(),
      );
}

//One full workout session log
class WorkoutSession {
  final String id;
  final String? templateId;
  final String? templateName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<WorkoutExerciseLog> exercises;

  WorkoutSession({
    required this.id,
    required this.templateId,
    required this.templateName,
    required this.startedAt,
    this.completedAt,
    required this.exercises,
  });

  WorkoutSession copyWith({
    String? id,
    String? templateId,
    String? templateName,
    DateTime? startedAt,
    DateTime? completedAt,
    List<WorkoutExerciseLog>? exercises,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toMap() => {
    'templateId': templateId,
    'templateName': templateName,
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
      templateName: data['templateName'],
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
