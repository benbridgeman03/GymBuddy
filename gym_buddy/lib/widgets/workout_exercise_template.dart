import 'package:flutter/material.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'package:gym_buddy/models/wokrout_template.dart';
import 'package:gym_buddy/services/min_sec_input_formatter.dart';
import 'package:gym_buddy/models/set_type.dart';

class WorkoutExerciseTemplate extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback? onRemove;

  const WorkoutExerciseTemplate({
    super.key,
    required this.exercise,
    this.onRemove,
  });

  @override
  State<WorkoutExerciseTemplate> createState() => WorkoutExerciseTemplateState();
}

class WorkoutExerciseTemplateState extends State<WorkoutExerciseTemplate> {
  List<Map<String, dynamic>> sets = [];

  void _addSet() {
    setState(() {
      int defaultRest = 60; // seconds
      int minutes = defaultRest ~/ 60;
      int seconds = defaultRest % 60;
      String formattedRest = '$minutes:${seconds.toString().padLeft(2, '0')}';

      sets.add({
        'reps': 8,
        'weight': 0.0,
        'rest': defaultRest,
        'restFormatted': formattedRest, // store formatted string for TextField
        'type': 'Working', // default type
      });
    });
  }

  void _removeSet(int index) {
    setState(() {
      sets.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _addSet();
  }

  WorkoutExercise toWorkoutExercise() {
    return WorkoutExercise(
      exerciseId: widget.exercise.id,
      name: widget.exercise.name,
      sets: sets.map((set) {
        return WorkoutSet(
          setType: SetType.values.firstWhere(
            (e) => e.name == (set['type'] ?? 'Working'),
            orElse: () => SetType.working,
          ),
          restSeconds: set['rest'] ?? 0,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 8, 28, 70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                widget.exercise.name,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close),
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          //Header Row
          Row(
            children: const [
              Expanded(
                flex: 1,
                child: Text(
                  'Type',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Reps',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Rest (s)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white30),

          //Sets List
          ...sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;

            set['type'] ??= 'Working';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Dismissible(
                key: ValueKey(set), // Unique key for each row
                direction:
                    DismissDirection.endToStart, // Swipe from right to left
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  setState(() {
                    _removeSet(index); // Remove the swiped set
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Set deleted')));
                },
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 36, // same height as TextFields
                        child: DropdownButtonFormField<String>(
                          initialValue:
                              set['type'] ?? 'Working', // default to Working
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          dropdownColor: Colors.blueGrey[900],
                          style: const TextStyle(color: Colors.white),
                          items: ['Warm-up', 'Working', 'Drop Set']
                              .map(
                                (label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(
                                    label,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              set['type'] = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: TextEditingController(
                            text: set['reps'].toString(),
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              set['reps'] = int.tryParse(value) ?? 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: TextEditingController(
                            text:
                                set['restFormatted'] ??
                                '', // optional: store formatted string
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [MinSecInputFormatter()],
                          onChanged: (value) {
                            set['restFormatted'] = value;
                            // convert to total seconds
                            final parts = value.split(':');
                            if (parts.length == 2) {
                              final min = int.tryParse(parts[0]) ?? 0;
                              final sec = int.tryParse(parts[1]) ?? 0;
                              set['rest'] = min * 60 + sec;
                            } else {
                              set['rest'] = int.tryParse(parts[0]) ?? 0;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          //Add Set Button
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton.icon(
              onPressed: _addSet,
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            ),
          ), // Additional UI elements for editing the exercise would go here
        ],
      ),
    );
  }
}
