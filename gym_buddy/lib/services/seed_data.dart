import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise.dart';
import '../models/bodypart.dart';

Future<void> seedDefaultExercises(String uid) async {
  final firestore = FirebaseFirestore.instance;
  final defaultExercises = [
    //Chest Exercises
    Exercise(
      id: 'bench_press_barbell',
      name: 'Bench Press',
      bodyPart: BodyPart.chest,
      category: ExcersizeCategory.barbell,
    ),
    Exercise(
      id: 'bench_press_dumbell',
      name: 'Bench Press',
      bodyPart: BodyPart.chest,
      category: ExcersizeCategory.dumbell,
    ),
    Exercise(
      id: 'bench_press_machine',
      name: 'Bench Press',
      bodyPart: BodyPart.chest,
      category: ExcersizeCategory.machine,
    ),
    Exercise(
      id: 'incline_bench_press_barbell',
      name: 'Incline Bench Press',
      bodyPart: BodyPart.chest,
      category: ExcersizeCategory.barbell,
    ),
    Exercise(
      id: 'incline_bench_press_dumbell',
      name: 'Incline Bench Press',
      bodyPart: BodyPart.chest,
      category: ExcersizeCategory.dumbell,
    ),
    Exercise(
      id: 'incline_bench_press_machine',
      name: 'Incline Bench Press',
      bodyPart: BodyPart.chest,
      category: ExcersizeCategory.machine,
    ),
    Exercise(
      id: 'chest_fly_machine',
      name: 'Chest Fly',
      bodyPart: BodyPart.chest,
      category: ExcersizeCategory.machine,
    ),
    Exercise(
      id: 'chest_fly_cable',
      name: 'Chest Fly',
      bodyPart: BodyPart.chest,
      category: ExcersizeCategory.cable,
    ),

    //Shoulder Exercises
    Exercise(
      id: 'shoulder_press_dumbell',
      name: 'Shoulder Press',
      bodyPart: BodyPart.shoulders,
      category: ExcersizeCategory.dumbell,
    ),
    Exercise(
      id: 'shoulder_press_machine',
      name: 'Shoulder Press',
      bodyPart: BodyPart.shoulders,
      category: ExcersizeCategory.machine,
    ),
    Exercise(
      id: 'lateral_raise_dumbell',
      name: 'Laterail Raise',
      bodyPart: BodyPart.shoulders,
      category: ExcersizeCategory.dumbell,
    ),
    Exercise(
      id: 'lateral_raise_cable',
      name: 'Laterail Raise',
      bodyPart: BodyPart.shoulders,
      category: ExcersizeCategory.cable,
    ),

    //Back Exercises
    Exercise(
      id: 'lat_pulldown',
      name: 'Lat Pulldown',
      bodyPart: BodyPart.back,
      category: ExcersizeCategory.machine,
    ),
    Exercise(
      id: 'deadlift',
      name: 'Deadlift',
      bodyPart: BodyPart.back,
      category: ExcersizeCategory.dumbell,
    ),

    //Biceps Exercises
    Exercise(
      id: 'preacher_curl_machine',
      name: 'Preacher Curl',
      bodyPart: BodyPart.biceps,
      category: ExcersizeCategory.machine,
    ),
    Exercise(
      id: 'preacher_curl_barbell',
      name: 'Preacher Curl',
      bodyPart: BodyPart.biceps,
      category: ExcersizeCategory.barbell,
    ),
    Exercise(
      id: 'hammer_curl_dumbell',
      name: 'Hammer Curl',
      bodyPart: BodyPart.biceps,
      category: ExcersizeCategory.dumbell,
    ),
    Exercise(
      id: 'bicep_curl_dumbell',
      name: 'Bicep Curl',
      bodyPart: BodyPart.biceps,
      category: ExcersizeCategory.dumbell,
    ),

    //Triceps Exercises
  ];

  for (var ex in defaultExercises) {
    final doc = firestore
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .doc(ex.id);

    final exists = await doc.get();
    if (!exists.exists) {
      await doc.set(ex.toMap());
    }
  }
}
