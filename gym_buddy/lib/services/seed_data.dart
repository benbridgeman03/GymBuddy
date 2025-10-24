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
    Exercise(
      id: 'shurgs_dumbell',
      name: 'Shrugs',
      bodyPart: BodyPart.shoulders,
      category: ExcersizeCategory.dumbell,
    ),

    //Back Exercises
    Exercise(
      id: 'lat_pulldown',
      name: 'Lat Pulldown',
      bodyPart: BodyPart.back,
      category: ExcersizeCategory.machine,
    ),
    Exercise(
      id: 'barbell_rows',
      name: 'Barbell Rows',
      bodyPart: BodyPart.back,
      category: ExcersizeCategory.barbell,
    ),
    Exercise(
      id: 'upper_back_rows_machine',
      name: 'Upper Back Rows',
      bodyPart: BodyPart.back,
      category: ExcersizeCategory.machine,
    ),
    Exercise(
      id: 'upper_back_rows_cable',
      name: 'Upper Back Rows',
      bodyPart: BodyPart.back,
      category: ExcersizeCategory.cable,
    ),
    Exercise(
      id: 'lower_back_rows_machine',
      name: 'Lower Back Rows',
      bodyPart: BodyPart.back,
      category: ExcersizeCategory.machine,
    ),
    Exercise(
      id: 'T_bar_rows_machine',
      name: 'T-Bar Rows',
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
      id: 'bicep_curl_dumbell',
      name: 'Bicep Curl',
      bodyPart: BodyPart.biceps,
      category: ExcersizeCategory.dumbell,
    ),
    Exercise(
      id: 'bicep_curl_cable',
      name: 'Bicep Curl',
      bodyPart: BodyPart.biceps,
      category: ExcersizeCategory.cable,
    ),
    Exercise(
      id: 'bicep_curl_barbell',
      name: 'Bicep Curl',
      bodyPart: BodyPart.biceps,
      category: ExcersizeCategory.cable,
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

    //Triceps Exercises
    Exercise(
      id: 'tricep_extension_dumbell',
      name: 'Tricep Extension',
      bodyPart: BodyPart.triceps,
      category: ExcersizeCategory.dumbell,
    ),
    Exercise(
      id: 'tricep_extension_cable',
      name: 'Tricep Extension',
      bodyPart: BodyPart.triceps,
      category: ExcersizeCategory.cable,
    ),
    Exercise(
      id: 'tricep_extension_machine',
      name: 'Tricep Extension',
      bodyPart: BodyPart.triceps,
      category: ExcersizeCategory.machine,
    ),
    Exercise(
      id: 'tricep_pushdown_cable',
      name: 'Tricep Pushdown',
      bodyPart: BodyPart.triceps,
      category: ExcersizeCategory.cable,
    ),
    Exercise(
      id: 'tricep_pushdown_machine',
      name: 'Tricep Pushdown',
      bodyPart: BodyPart.triceps,
      category: ExcersizeCategory.machine,
    ),
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
