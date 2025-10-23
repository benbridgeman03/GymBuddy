import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'package:gym_buddy/models/wokrout_template.dart';
import 'package:gym_buddy/widgets/workout_exercise_template.dart';
import '../widgets/exercise_picker.dart';

class TemplateView extends StatefulWidget {
  const TemplateView({super.key});

  @override
  State<TemplateView> createState() => _TemplateView();
}

class _TemplateView extends State<TemplateView> {
  final List<Exercise> _workoutExercises = [];
  final List<GlobalKey<WorkoutExerciseTemplateState>> _editorKeys = [];

  final TextEditingController _templateName = TextEditingController();

  /// Opens the exercise picker dialog directly (no small dialog first)
  void _openExercisePicker(
    BuildContext context,
    String uid, {
    WorkoutExercise? existing,
  }) async {
    String? selectedExerciseId = existing?.exerciseId;
    String exerciseName = existing?.name ?? '';

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

  void _saveTemplate() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final exercises = <WorkoutExercise>[];

    for (var i = 0; i < _editorKeys.length; i++) {
      final state = _editorKeys[i].currentState;
      if (state == null) continue;
      exercises.add(state.toWorkoutExercise());
    }

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template cannot be empty!')),
      );
      return;
    }

    if (_templateName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a template name!')),
      );
      return;
    }

    final template = WorkoutTemplate(
      id: '',
      name: _templateName.text.trim(),
      exercises: exercises,
      createdAt: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('templates')
        .add(template.toMap());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template saved successfully!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
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
                // Title Row
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
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      icon: const Icon(Icons.close),
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _templateName,
                  decoration: const InputDecoration(labelText: 'Template Name'),
                ),
                const SizedBox(height: 16),
                ..._workoutExercises.map(
                  (ex) => WorkoutExerciseTemplate(
                    key: _editorKeys[_workoutExercises.indexOf(ex)],
                    exercise: ex,
                    onRemove: () {
                      setState(() {
                        _removeExercise(ex);
                      });
                    },
                  ),
                ),

                // Add Exercise Button
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
                    onPressed: _saveTemplate,
                    child: const Text('Save Template'),
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
