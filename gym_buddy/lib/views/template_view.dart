import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'package:gym_buddy/models/workout_template.dart';
import 'package:gym_buddy/widgets/workout_exercise_template.dart';
import 'package:provider/provider.dart';
import '../widgets/exercise_picker.dart';
import '../providers/exercise_provider.dart';

class TemplateView extends StatefulWidget {
  final WorkoutTemplate? existingTemplate;
  const TemplateView({super.key, this.existingTemplate});

  @override
  State<TemplateView> createState() => _TemplateView();
}

class _TemplateView extends State<TemplateView> {
  final List<Exercise> _workoutExercises = [];
  final List<GlobalKey<WorkoutExerciseTemplateState>> _editorKeys = [];

  final TextEditingController _templateName = TextEditingController();

  @override
  void initState() {
    super.initState();
    final t = widget.existingTemplate;
    if (t != null) {
      _templateName.text = t.name;
      _workoutExercises.addAll(t.exercises.map((ex) => ex.exercise));
      _editorKeys.addAll(
        t.exercises.map((_) => GlobalKey<WorkoutExerciseTemplateState>()),
      );
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
    final existingId = widget.existingTemplate?.id;

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

    final templateData = template.toMap();

    if (existingId == null) {
      // New template
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('templates')
          .add(templateData);
    } else {
      // Existing template: update
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('templates')
          .doc(existingId)
          .set(templateData); // overwrites existing
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template saved successfully!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _deleteTemplate() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final existingId = widget.existingTemplate?.id;
    if (existingId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('templates')
        .doc(existingId)
        .delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template deleted successfully!')),
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

                const SizedBox(height: 8),

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

                if (widget.existingTemplate != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Template?'),
                            content: const Text(
                              'Are you sure you want to Delete this template?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete ?? false) {
                          _deleteTemplate();
                        }
                      },
                      child: const Text('Delete Template'),
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
