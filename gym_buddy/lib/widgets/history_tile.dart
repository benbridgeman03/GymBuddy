import 'package:flutter/material.dart';
import 'package:gym_buddy/models/set_type.dart';
import 'package:gym_buddy/models/workout_log.dart';
import 'package:gym_buddy/services/get_time_of_day.dart';
import 'package:intl/intl.dart';

class HistoryTile extends StatefulWidget {
  final WorkoutSession workout;

  const HistoryTile({super.key, required this.workout});

  @override
  State<HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        print('Workout tapped!');
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 8, 28, 70),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    widget.workout.templateName ??
                        '${getTimeOfDay(widget.workout.startedAt)} Workout',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('EEEE, MMM d').format(widget.workout.startedAt),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...widget.workout.exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exerciseLog = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == widget.workout.exercises.length - 1
                        ? 0
                        : 4.0,
                  ),
                  child: Text(
                    "${exerciseLog.exercise.name} x ${exerciseLog.sets.where((ex) => ex.setType != SetType.warmup).length}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
