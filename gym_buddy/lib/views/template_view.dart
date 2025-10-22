import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'package:gym_buddy/models/wokrout_template.dart';

class TemplateView extends StatelessWidget {
  const TemplateView({super.key});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Row(
                children: [
                  Text(
                    'New Template',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Add Exercise Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    openExercisePicker(context, uid);
                  },
                  child: const Text('Add Exercise'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the exercise picker dialog directly (no small dialog first)
  void openExercisePicker(
    BuildContext context,
    String uid, {
    WorkoutExercise? existing,
  }) async {
    String? selectedExerciseId = existing?.exerciseId;
    String exerciseName = existing?.name ?? '';

    // 🔹 Load exercises from Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .get();

    final exercises = snapshot.docs
        .map((doc) => Exercise.fromDoc(doc))
        .toList();

    // 🔹 Open the big picker dialog directly
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

      // TODO: Do whatever you need with the selected exercise here
      // e.g., save to workout template or update Firestore
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Selected: $exerciseName')));
    }
  }
}

class ExercisePickerDialog extends StatefulWidget {
  final List<Exercise> exercises;
  final String? selectedId;

  const ExercisePickerDialog({
    super.key,
    required this.exercises,
    this.selectedId,
  });

  @override
  State<ExercisePickerDialog> createState() => _ExercisePickerDialogState();
}

class _ExercisePickerDialogState extends State<ExercisePickerDialog> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    // Filter and sort alphabetically
    final filtered =
        widget.exercises
            .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    // Group by first letter
    final Map<String, List<Exercise>> grouped = {};
    for (var e in filtered) {
      final letter = e.name[0].toUpperCase();
      grouped.putIfAbsent(letter, () => []).add(e);
    }

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 8, 28, 70),
      title: const Text(
        'Select Exercise',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 450,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => setState(() => query = val),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Scrollbar(
                child: ListView(
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        ...entry.value.map((e) {
                          final isSelected = e.id == widget.selectedId;
                          return ListTile(
                            title: Text(
                              e.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            tileColor: isSelected
                                ? Colors.blueGrey.withOpacity(0.4)
                                : null,
                            onTap: () => Navigator.pop(context, e.id),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
