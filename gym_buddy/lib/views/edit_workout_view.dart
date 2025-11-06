import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'package:gym_buddy/models/workout_log.dart';
import 'package:gym_buddy/models/workout_template.dart';
import 'package:gym_buddy/providers/exercise_provider.dart';
import 'package:gym_buddy/widgets/exercise_picker.dart';
import 'package:gym_buddy/widgets/workout_exercise_log_template.dart';
import 'package:provider/provider.dart';

class EditHistoryView extends StatefulWidget {
  final WorkoutSession workout;
  const EditHistoryView({super.key, required this.workout});

  @override
  State<EditHistoryView> createState() => _EditHistoryViewState();
}

class _EditHistoryViewState extends State<EditHistoryView> {
  final List<Exercise> _workoutExercises = [];
  final List<WorkoutExerciseLog> _exerciseLogs = [];
  final List<GlobalKey<WorkoutExerciseLogTemplateState>> _editorKeys = [];

  @override
  void initState() {
    super.initState();

    final workout = widget.workout;

    for (final exerciseLog in workout.exercises) {
      _exerciseLogs.add(exerciseLog);
      _editorKeys.add(GlobalKey<WorkoutExerciseLogTemplateState>());
    }
  }

  void _openExercisePicker(
    BuildContext context,
    String uid, {
    WorkoutExercise? existing,
  }) async {
    Exercise? selectedExerciseId = existing?.exercise;
    String exerciseName = existing?.exercise.name ?? '';

    final provider = context.read<ExerciseProvider>();
    final exercises = provider.exercises;

    final selected = await showDialog<String>(
      context: context,
      builder: (_) => ExercisePickerDialog(
        exercises: exercises,
        selectedId: selectedExerciseId,
      ),
    );

    if (selected != null) {
      final chosen = exercises.firstWhere((ex) => ex.id == selected);
      exerciseName = chosen.name;
      _addExercise(chosen);
    }
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      _workoutExercises.add(exercise);
      _editorKeys.add(GlobalKey<WorkoutExerciseLogTemplateState>());
    });
  }

  void _removeExercise(Exercise exercise) {
    final index = _exerciseLogs.indexWhere(
      (log) => log.exercise.id == exercise.id,
    );
    if (index != -1) {
      setState(() {
        _exerciseLogs.removeAt(index);
        _editorKeys.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('Please log in.'));
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'New Template',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      color: Colors.red,
                    ),
                  ],
                ),
                ..._exerciseLogs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exerciseLog = entry.value;

                  return WorkoutExerciseLogTemplate(
                    key: _editorKeys[index],
                    exerciseLog: exerciseLog,
                    onRemove: () => _removeExercise(exerciseLog.exercise),
                  );
                }),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () => _openExercisePicker(context, uid),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
