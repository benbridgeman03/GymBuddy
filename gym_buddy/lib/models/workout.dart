import 'workout_set.dart';

class Workout {
  final List<WorkoutSet> sets;
  final DateTime startTime;
  final DateTime endTime;

  Workout({
    required this.sets,
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);

  double get totalWeight {
    double total = 0;
    for (final set in sets) {
      total += set.weight * set.reps;
    }
    return total;
  }
}
