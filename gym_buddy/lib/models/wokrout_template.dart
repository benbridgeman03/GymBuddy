import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'set_type.dart';

//one set definition in a workout template
class WorkoutSet {
  final SetType setType;
  final int restSeconds; // rest after this set, before the next one

  WorkoutSet({required this.setType, required this.restSeconds});

  Map<String, dynamic> toMap() => {
    'setType': setType.name,
    'restSeconds': restSeconds,
  };

  factory WorkoutSet.fromMap(Map<String, dynamic> data) => WorkoutSet(
    setType: SetType.values.firstWhere((e) => e.name == data['setType']),
    restSeconds: data['restSeconds'] ?? 0,
  );
}

class WorkoutExercise {
  final Exercise exercise;
  final List<WorkoutSet> sets;

  WorkoutExercise({required this.exercise, required this.sets});

  Map<String, dynamic> toMap() => {
    'exercise': exercise.toMap(), // ✅ convert to map
    'sets': sets.map((s) => s.toMap()).toList(),
  };

  factory WorkoutExercise.fromMap(Map<String, dynamic> data) => WorkoutExercise(
    exercise: Exercise.fromMap(data['exercise']),
    sets: (data['sets'] as List<dynamic>)
        .map((s) => WorkoutSet.fromMap(s))
        .toList(),
  );
}

class WorkoutTemplate {
  final String id;
  final String name;
  final List<WorkoutExercise> exercises;
  final DateTime createdAt;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.exercises,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'createdAt': Timestamp.fromDate(createdAt),
    'exercises': exercises.map((e) => e.toMap()).toList(),
  };

  factory WorkoutTemplate.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutTemplate(
      id: doc.id,
      name: data['name'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      exercises: (data['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercise.fromMap(e))
          .toList(),
    );
  }
}
