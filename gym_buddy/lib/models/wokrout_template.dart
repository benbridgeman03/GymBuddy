import 'package:cloud_firestore/cloud_firestore.dart';

enum SetType { warmup, working, cooldown }

class WorkoutExercise {
  final String excersiseId;
  final String name;
  final int sets;
  final SetType setType;

  WorkoutExercise({
    required this.excersiseId,
    required this.name,
    required this.sets,
    required this.setType,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': excersiseId,
      'name': name,
      'sets': sets,
      'setType': setType.name,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> data) {
    return WorkoutExercise(
      excersiseId: data['exerciseId'],
      name: data['name'],
      sets: data['sets'],
      setType: SetType.values.firstWhere((e) => e.name == data['setType']),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

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
