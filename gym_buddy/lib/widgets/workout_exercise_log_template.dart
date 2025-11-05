import 'package:flutter/material.dart';
import 'package:gym_buddy/models/exercise.dart';
import 'package:gym_buddy/models/workout_log.dart';
import 'package:gym_buddy/services/min_sec_input_formatter.dart';
import 'package:gym_buddy/models/set_type.dart';
import 'dart:async';

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

  List<int> countdowns = [];
  List<Timer?> timers = [];
  List<bool> isRunning = [];

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
      (i) => TextEditingController(text: ''),
    );

    repsControllers = List.generate(
      sets.length,
      (i) => TextEditingController(text: sets[i]['reps'].toString()),
    );

    restControllers = List.generate(
      sets.length,
      (i) => TextEditingController(text: sets[i]['restFormatted']),
    );

    countdowns = List.generate(sets.length, (i) => 0);
    timers = List.generate(sets.length, (i) => null);
    isRunning = List.generate(sets.length, (_) => false);
  }

  void _addSet() {
    setState(() {
      int defaultRest = 180;
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

      countdowns.add(0);
      timers.add(null);
      isRunning.add(false);
    });
  }

  void _removeSet(int index) {
    setState(() {
      timers[index]?.cancel();
      timers.removeAt(index);
      countdowns.removeAt(index);
      sets.removeAt(index);
      weightControllers.removeAt(index);
      repsControllers.removeAt(index);
      restControllers.removeAt(index);
    });
  }

  void _startRestCountdown(int index, {int? initialSeconds}) {
    timers[index]?.cancel();

    int restSeconds = initialSeconds ?? 0;

    setState(() {
      countdowns[index] = restSeconds;
      isRunning[index] = true;
    });

    timers[index] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdowns[index] > 0) {
        setState(() {
          countdowns[index]--;

          // Update the TextField
          final minutes = (countdowns[index] ~/ 60).toString().padLeft(2, '0');
          final seconds = (countdowns[index] % 60).toString().padLeft(2, '0');
          restControllers[index].text = '$minutes:$seconds';
          restControllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: restControllers[index].text.length),
          );
        });
      } else {
        timer.cancel();
        isRunning[index] = false;
      }
    });
  }

  void _stopAllCountdowns(int index) {
    for (int i = 0; i < index; i++) {
      if (isRunning[i]) {
        timers[i]?.cancel();
        timers[i] = null;
        isRunning[i] = false;
        countdowns[i] = 0;
        restControllers[i].text = '0:00';
      }
    }
    setState(() {});
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
              Expanded(
                flex: 2, // Type
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
                flex: 1, // Weight
                child: Text(
                  'Weight',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1, // Reps
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
                flex: 1, // fixed width
                child: Icon(
                  Icons.check, // or Icons.done
                  color: Colors.grey,
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
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Type
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                initialValue: setTypesMap.entries
                                    .firstWhere(
                                      (e) => e.value.name == set['type'],
                                      orElse: () =>
                                          setTypesMap.entries.firstWhere(
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
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
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
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(),
                                  hintText: '8',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                onChanged: (value) => sets[index]['reps'] =
                                    int.tryParse(value) ?? 0,
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
                                      sets[index]['isComplete'] =
                                          value ?? false;
                                      if (value == true) {
                                        _stopAllCountdowns(index);

                                        final parts = restControllers[index]
                                            .text
                                            .split(':');
                                        int totalSeconds = 0;
                                        if (parts.length == 2) {
                                          final min =
                                              int.tryParse(parts[0]) ?? 0;
                                          final sec =
                                              int.tryParse(parts[1]) ?? 0;
                                          totalSeconds = min * 60 + sec;
                                        } else {
                                          totalSeconds =
                                              int.tryParse(parts[0]) ?? 0;
                                        }
                                        _startRestCountdown(
                                          index,
                                          initialSeconds: totalSeconds,
                                        );
                                      } else {
                                        timers[index]?.cancel();
                                        countdowns[index] = 0;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: countdowns[index] == 0
                                      ? Colors.green
                                      : Colors.white30,
                                  thickness: 1,
                                  endIndent: 8,
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Center(
                                  child: TextField(
                                    controller: restControllers[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      hintText: 'mm:ss',
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(color: Colors.green),
                                    inputFormatters: [MinSecInputFormatter()],

                                    // Called when the user finishes editing
                                    onSubmitted: (value) {
                                      final parts = value.split(':');
                                      int totalSeconds = 0;
                                      if (parts.length == 2) {
                                        final min = int.tryParse(parts[0]) ?? 0;
                                        final sec = int.tryParse(parts[1]) ?? 0;
                                        totalSeconds = min * 60 + sec;
                                      } else {
                                        totalSeconds =
                                            int.tryParse(parts[0]) ?? 0;
                                      }

                                      // Restart countdown from new value if checkbox is checked
                                      if (sets[index]['isComplete'] == true) {
                                        _startRestCountdown(
                                          index,
                                          initialSeconds: totalSeconds,
                                        );
                                      }
                                    },

                                    onChanged: (value) {
                                      timers[index]?.cancel();
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: countdowns[index] == 0
                                      ? Colors.green
                                      : Colors.white30,
                                  thickness: 1,
                                  indent: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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
          ),
        ],
      ),
    );
  }
}
