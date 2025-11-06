import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'package:gym_buddy/models/set_type.dart';
import 'package:gym_buddy/models/workout_log.dart';
import 'package:gym_buddy/providers/exercise_provider.dart';
import 'package:gym_buddy/widgets/exercise_picker.dart';
import 'package:gym_buddy/widgets/workout_exercise_log_template.dart';
import 'package:provider/provider.dart';
import '../providers/panel_manager.dart';
import 'package:gym_buddy/models/workout_template.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/workout_manager.dart';

class WorkoutView extends StatefulWidget {
  final ScrollController? scrollController;
  const WorkoutView({super.key, this.scrollController});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  final List<Exercise> _workoutExercises = [];
  final List<GlobalKey<WorkoutExerciseLogTemplateState>> _editorKeys = [];
  bool workoutStarted = false;
  final String _templateName = 'Empty Workout';

  WorkoutTemplate? _loadedTemplate;

  void reset(BuildContext context) {
    context.read<WorkoutManager>().reset();
    setState(() {
      _workoutExercises.clear();
      _editorKeys.clear();
      workoutStarted = false;
      _loadedTemplate = null;
    });
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
    print("added workout");
    setState(() {
      _workoutExercises.add(exercise);
      _editorKeys.add(GlobalKey<WorkoutExerciseLogTemplateState>());
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

  void _loadTemplateExercises(WorkoutTemplate template) {
    if (_loadedTemplate == template) return;
    _loadedTemplate = template;

    _workoutExercises.clear();
    _editorKeys.clear();

    for (final workoutExercise in template.exercises) {
      _addExercise(workoutExercise.exercise);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final panelManager = context.read<PanelManager>();
    final template = panelManager.activeTemplate;

    if (template != null) {
      _loadTemplateExercises(template);
    }
  }

  void _saveWorkout() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final provider = context.read<WorkoutManager>();
    final startedAt = provider.startedAt ?? DateTime.now();

    final exercises = <WorkoutExerciseLog>[];

    for (var i = 0; i < _editorKeys.length; i++) {
      final state = _editorKeys[i].currentState;
      if (state == null) continue;
      exercises.add(state.toWorkoutExerciseLog());
    }

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template cannot be empty!')),
      );
      return;
    }

    final template = WorkoutSession(
      id: '',
      exercises: exercises,
      templateId: _loadedTemplate?.id,
      templateName: _loadedTemplate?.name,
      startedAt: startedAt,
      completedAt: DateTime.now(),
    );

    final templateData = template.toMap();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .add(templateData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved successfully!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }

    provider.reset();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('Please log in.'));
    }

    final panelManager = context.watch<PanelManager>();
    final template = panelManager.activeTemplate;

    if (template != null && _loadedTemplate != template) {
      _loadTemplateExercises(template);
    }

    return Scaffold(
      body: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      _loadedTemplate?.name ?? _templateName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
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

                final List<WorkoutSetLog> initialSets =
                    (_loadedTemplate != null &&
                        index < _loadedTemplate!.exercises.length)
                    ? List<WorkoutSetLog>.from(
                        _loadedTemplate!.exercises[index].sets as List<dynamic>,
                      )
                    : [
                        WorkoutSetLog(
                          setType: SetType.working,
                          reps: 8,
                          weight: 0,
                          restSeconds: 180,
                        ),
                      ];

                return WorkoutExerciseLogTemplate(
                  key: _editorKeys[index],
                  exerciseLog: WorkoutExerciseLog(
                    exercise: exercise,
                    sets: initialSets,
                  ),
                  onRemove: () => _removeExercise(exercise),
                );
              }).toList(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openExercisePicker(context, uid),
                  child: const Text('Add Exercise'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveWorkout(),
                  child: const Text('Finish Workout'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        ],
      ),
    );
  }
}
