import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'package:gym_buddy/models/wokrout_template.dart';

import '../widgets/exercise_picker.dart';

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
