import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'package:gym_buddy/models/wokrout_template.dart';
import 'package:dropdown_search/dropdown_search.dart';

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
              // Title
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    upsertExercise(context, uid);
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

  void upsertExercise(
    BuildContext context,
    String uid, {
    WorkoutExercise? existing,
  }) async {
    String? selectedExerciseId = existing?.excersiseId;
    String exerciseName = existing?.name ?? '';
    int reps = existing?.sets ?? 0;
    SetType setType = existing?.setType ?? SetType.working;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .get();

    final exercises = snapshot.docs
        .map((doc) => Exercise.fromDoc(doc))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(existing == null ? 'Add Exercise' : 'Edit Exercise'),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              color: Colors.white,
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedExerciseId,
                  decoration: const InputDecoration(labelText: 'Exercise'),
                  dropdownColor: Color.fromARGB(255, 8, 28, 70),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white70,
                  items: exercises
                      .map(
                        (exercise) => DropdownMenuItem<String>(
                          value: exercise.id,
                          child: Text(
                            exercise.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() {
                    selectedExerciseId = val!;
                    final selected = exercises.firstWhere(
                      (ex) => ex.id == val,
                      orElse: () => exercises.first,
                    );
                    exerciseName = selected.name;
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
