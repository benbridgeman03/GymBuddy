import 'package:flutter/material.dart';
import 'package:gym_buddy/models/exercise.dart';

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
