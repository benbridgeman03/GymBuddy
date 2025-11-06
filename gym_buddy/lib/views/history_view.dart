import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_buddy/models/bodypart.dart';
import 'package:gym_buddy/models/workout_log.dart';
import 'package:gym_buddy/models/workout_template.dart';
import 'package:gym_buddy/providers/history_provider.dart';
import 'package:gym_buddy/widgets/history_tile.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../services/string_extension.dart';
import '../providers/exercise_provider.dart';
import 'package:intl/intl.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

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
              Row(
                children: [
                  // Title
                  Text(
                    'History',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.hardEdge,
                  child: Consumer<HistoryProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final workouts = provider.workouts;

                      if (workouts.isEmpty) {
                        return const Center(child: Text('No workouts found.'));
                      }

                      final Map<String, List<WorkoutSession>> grouped = {};

                      for (final workout in workouts) {
                        final key = DateFormat(
                          'MMMM yyyy',
                        ).format(workout.startedAt);
                        grouped.putIfAbsent(key, () => []).add(workout);
                      }

                      final months = grouped.entries.toList();

                      return ListView.builder(
                        itemCount: grouped.length,
                        itemBuilder: (context, index) {
                          final entry = months[index];
                          final month = entry.key;
                          final workouts = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Letter header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  month,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              ...workouts.map(
                                (w) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: HistoryTile(workout: w),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
