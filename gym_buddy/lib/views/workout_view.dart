import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'package:gym_buddy/widgets/exercise_picker.dart';
import 'package:gym_buddy/widgets/workout_exercise_template.dart';
import 'package:provider/provider.dart';
import '../providers/panel_manager.dart';
import 'package:gym_buddy/models/wokrout_template.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/workout_manager.dart';

class WorkoutView extends StatefulWidget {
  final WorkoutTemplate? existingTemplate;
  const WorkoutView({super.key, this.existingTemplate});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  final List<Exercise> _workoutExercises = [];
  final List<GlobalKey<WorkoutExerciseTemplateState>> _editorKeys = [];
  bool workoutStarted = false;

  final String _templateName = 'Empty Workout';

  void reset(BuildContext context) {
    context.read<WorkoutManager>().reset();
    setState(() {
      _workoutExercises.clear();
      _editorKeys.clear();
      workoutStarted = false;
    });
  }

  void _openExercisePicker(
    BuildContext context,
    String uid, {
    WorkoutExercise? existing,
  }) async {
    Exercise? selectedExerciseId = existing?.exercise;
    String exerciseName = existing?.exercise.name ?? '';

    // Load exercises from Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .get();

    final exercises = snapshot.docs
        .map((doc) => Exercise.fromDoc(doc))
        .toList();

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
      _editorKeys.add(GlobalKey<WorkoutExerciseTemplateState>());
    });
  }

  void _removeExercise(Exercise exercise) {
    final index = _workoutExercises.indexOf(exercise);
    if (index != -1) {
      setState(() {
        _workoutExercises.removeAt(index);
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

    final panelManager = Provider.of<PanelManager>(context, listen: false);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grab handle
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft, // Aligns text to the left
                  child: Row(
                    children: [
                      Text(
                        _templateName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Consumer<WorkoutManager>(
                        builder: (_, controller, __) {
                          final minutes =
                              controller.elapsedTime.elapsed.inMinutes;
                          final seconds =
                              (controller.elapsedTime.elapsed.inSeconds % 60)
                                  .toString()
                                  .padLeft(2, '0');
                          return Text(
                            '$minutes:$seconds',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                ..._workoutExercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  final initialSets =
                      (widget.existingTemplate != null &&
                          index < widget.existingTemplate!.exercises.length)
                      ? widget.existingTemplate!.exercises[index].sets
                            .map(
                              (s) => {
                                'type': s.setType.name,
                                'rest': s.restSeconds,
                                'restFormatted':
                                    '${s.restSeconds ~/ 60}:${(s.restSeconds % 60).toString().padLeft(2, '0')}',
                                'reps': s.reps,
                              },
                            )
                            .toList()
                      : null;

                  return WorkoutExerciseTemplate(
                    key: _editorKeys[index],
                    exercise: exercise,
                    initialSets: initialSets,
                    onRemove: () {
                      setState(() {
                        _removeExercise(exercise);
                      });
                    },
                  );
                }),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _openExercisePicker(context, uid);
                    },
                    child: const Text('Add Exercise'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {},
                    child: const Text('Finish Workout'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      final shouldCancel = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Cancel Workout?'),
                          content: const Text(
                            'Are you sure you want to cancel this workout? Your progress will be lost.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      );

                      if (shouldCancel ?? false) {
                        reset(context);
                        panelManager.closePanel();
                      }
                    },
                    child: const Text('Cancel Workout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
