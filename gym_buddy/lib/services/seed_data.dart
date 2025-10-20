import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise.dart';
import '../models/bodypart.dart';

Future<void> seedDefaultExercises() async {
  final firestore = FirebaseFirestore.instance;
  final defaultExercises = [
    Exercise(
      id: 'bench_press',
      name: 'Bench Press',
      bodyPart: BodyPart.chest,
      category: ExcersizeCategory.barbell,
    ),
    Exercise(
      id: 'incline_bench_press',
      name: 'Incline Bench Press',
      bodyPart: BodyPart.chest,
      category: ExcersizeCategory.barbell,
    ),
    Exercise(
      id: 'squat',
      name: 'Squat',
      bodyPart: BodyPart.legs,
      category: ExcersizeCategory.barbell,
    ),
    Exercise(
      id: 'lat_pulldown',
      name: 'Lat Pulldown',
      bodyPart: BodyPart.back,
      category: ExcersizeCategory.machine,
    ),
    Exercise(
      id: 'preacher_curl',
      name: 'Preacher Curl',
      bodyPart: BodyPart.biceps,
      category: ExcersizeCategory.machine,
    ),
  ];

  for (final ex in defaultExercises) {
    final doc = firestore.collection('exercises').doc(ex.id);
    final exists = await doc.get();
    if (!exists.exists) {
      await doc.set(ex.toMap());
    }
  }
}
