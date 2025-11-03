import 'package:flutter/material.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'package:gym_buddy/models/workout_log.dart';
import 'package:gym_buddy/services/min_sec_input_formatter.dart';
import 'package:gym_buddy/models/set_type.dart';

class WorkoutExerciseLogTemplate extends StatefulWidget {
  final Exercise exercise;
  final List<Map<String, dynamic>>? initialSets;
  final VoidCallback? onRemove;

  const WorkoutExerciseLogTemplate({
    super.key,
    required this.exercise,
    this.initialSets,
    this.onRemove,
  });

  @override
  State<WorkoutExerciseLogTemplate> createState() =>
      WorkoutExerciseLogTemplateState();
}

class WorkoutExerciseLogTemplateState
    extends State<WorkoutExerciseLogTemplate> {
  List<Map<String, dynamic>> sets = [];

  List<TextEditingController> weightControllers = [];
  List<TextEditingController> repsControllers = [];
  List<TextEditingController> restControllers = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialSets != null && widget.initialSets!.isNotEmpty) {
      sets = List<Map<String, dynamic>>.from(widget.initialSets!);
    } else {
      _addSet(); // adds first set and controllers
    }

    // Make sure controllers exist for all sets
    weightControllers = List.generate(
      sets.length,
      (i) => TextEditingController(text: '0'),
    );

    repsControllers = List.generate(
      sets.length,
      (i) => TextEditingController(text: sets[i]['reps'].toString()),
    );

    restControllers = List.generate(
      sets.length,
      (i) => TextEditingController(text: sets[i]['restFormatted']),
    );
  }

  void _addSet() {
    setState(() {
      int defaultRest = 180; // seconds
      int minutes = defaultRest ~/ 60;
      int seconds = defaultRest % 60;
      String formattedRest = '$minutes:${seconds.toString().padLeft(2, '0')}';

      sets.add({
        'reps': 8,
        'weight': 0.0,
        'rest': defaultRest,
        'restFormatted': formattedRest,
        'type': 'Working',
        'isComplete': false,
      });

      weightControllers.add(TextEditingController(text: '0'));
      repsControllers.add(TextEditingController(text: '8'));
      restControllers.add(TextEditingController(text: formattedRest));
    });
  }

  void _removeSet(int index) {
    setState(() {
      sets.removeAt(index);
    });
  }

  WorkoutExerciseLog toWorkoutExerciseLog() {
    return WorkoutExerciseLog(
      exercise: widget.exercise,
      sets: sets.map((set) {
        return WorkoutSetLog(
          setType: SetType.values.firstWhere(
            (e) => e.name == (set['type'] ?? 'Working'),
            orElse: () => SetType.working,
          ),
          reps: set['reps'] ?? 0,
          restSeconds: set['rest'] ?? 0,
          weight: set['weight'] ?? 0,
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
              SizedBox(width: 18),
              SizedBox(
                width: 80, // Type
                child: Text(
                  'Type',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12), // optional spacing

              SizedBox(
                width: 60, // Weight
                child: Text(
                  'Weight',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12), // optional spacing

              SizedBox(
                width: 60, // Reps
                child: Text(
                  'Reps',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12), // optional spacing

              SizedBox(
                width: 60, // Rest
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
                key: ValueKey(set),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  setState(() {
                    _removeSet(index);
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Set deleted')));
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Type
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: setTypesMap.entries
                                .firstWhere(
                                  (e) => e.value.name == set['type'],
                                  orElse: () => setTypesMap.entries.firstWhere(
                                    (e) => e.key == 'Working',
                                  ),
                                )
                                .key,
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
                            items: setTypesMap.keys
                                .map(
                                  (label) => DropdownMenuItem(
                                    value: label,
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                set['type'] = setTypesMap[value!]!.name;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Weight
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: weightControllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              border: OutlineInputBorder(),
                              hintText: '0',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onChanged: (value) => sets[index]['weight'] =
                                double.tryParse(value) ?? 0.0,
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Reps
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: repsControllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              border: OutlineInputBorder(),
                              hintText: '8',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onChanged: (value) =>
                                sets[index]['reps'] = int.tryParse(value) ?? 0,
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Rest
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: restControllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [MinSecInputFormatter()],
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              border: OutlineInputBorder(),
                              hintText: '3:00',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onChanged: (value) {
                              sets[index]['restFormatted'] = value;
                              final parts = value.split(':');
                              if (parts.length == 2) {
                                final min = int.tryParse(parts[0]) ?? 0;
                                final sec = int.tryParse(parts[1]) ?? 0;
                                sets[index]['rest'] = min * 60 + sec;
                              } else {
                                sets[index]['rest'] =
                                    int.tryParse(parts[0]) ?? 0;
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Complete Checkbox
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Checkbox(
                              value: sets[index]['isComplete'] ?? false,
                              activeColor: Colors.green,
                              onChanged: (bool? value) {
                                setState(() {
                                  sets[index]['isComplete'] = value ?? false;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
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
