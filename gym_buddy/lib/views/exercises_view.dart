import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_buddy/models/bodypart.dart';
import '../models/exercise.dart';
import '../services/string_extension.dart';

class ExcersizesView extends StatelessWidget {
  const ExcersizesView({super.key});

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
                    'Exercises',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(), // pushes the button to the far right
                  // Add button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        upsertExercise(context, uid);
                      },
                      icon: const Icon(Icons.add),
                      color: Colors.white,
                      iconSize: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              //Exercise List
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.hardEdge,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('exercises')
                        .orderBy('name')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No exercises found.'));
                      }
                      final exercises = snapshot.data!.docs
                          .map((doc) => Exercise.fromDoc(doc))
                          .toList();

                      Map<String, List<Exercise>> grouped = {};
                      for (var ex in exercises) {
                        String firstLetter = ex.name[0].toUpperCase();
                        grouped.putIfAbsent(firstLetter, () => []).add(ex);
                      }

                      final letters = grouped.keys.toList()..sort();
                      return ListView.builder(
                        itemCount: letters.length,
                        itemBuilder: (context, index) {
                          String letter = letters[index];
                          final exList = grouped[letter]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Letter header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  letter,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Exercises under this letter
                              ...exList.map(
                                (ex) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => upsertExercise(
                                        context,
                                        uid,
                                        existing: ex,
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                              ),
                                          title: Text(
                                            ex.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16, // adjust as needed
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${ex.bodyPart.name.capitalize()} • ${ex.category.name.capitalize()}',
                                            style: TextStyle(
                                              color: Colors
                                                  .grey[400], // slightly lighter color
                                              fontSize: 12, // smaller font
                                              fontStyle: FontStyle
                                                  .italic, // optional styling
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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

  void upsertExercise(BuildContext context, String uid, {Exercise? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    BodyPart selectedBodyPart = existing?.bodyPart ?? BodyPart.chest;
    ExcersizeCategory selectedCategory =
        existing?.category ?? ExcersizeCategory.dumbell;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(existing == null ? 'Add Exercise' : 'Edit Exercise'),
            if (existing != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                tooltip: 'Delete Exercise',
                onPressed: () async {
                  // Confirm before deleting
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Exercise'),
                      content: Text(
                        'Are you sure you want to delete "${existing.name}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  // If user confirmed delete
                  if (confirm == true) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('exercises')
                        .doc(existing.id)
                        .delete();
                    Navigator.pop(context); // Close main dialog
                  }
                },
              ),
          ],
        ),

        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Exercise Name'),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<BodyPart>(
                  initialValue: selectedBodyPart,
                  decoration: const InputDecoration(labelText: 'Body Part'),
                  dropdownColor: Color.fromARGB(255, 8, 28, 70),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white70,
                  items: BodyPart.values
                      .map(
                        (b) => DropdownMenuItem(
                          value: b,
                          child: Text(b.name.capitalize()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() {
                    selectedBodyPart = val!;
                  }),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<ExcersizeCategory>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  dropdownColor: Color.fromARGB(255, 8, 28, 70),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white70,
                  items: ExcersizeCategory.values
                      .map(
                        (b) => DropdownMenuItem(
                          value: b,
                          child: Text(b.name.capitalize()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() {
                    selectedCategory = val!;
                  }),
                ),
              ],
            ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final id =
                  existing?.id ?? name.toLowerCase().replaceAll(' ', '_');

              final newExercise = Exercise(
                id: id,
                name: name,
                bodyPart: selectedBodyPart,
                category: selectedCategory,
              );

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('exercises')
                  .doc(id)
                  .set(newExercise.toMap(), SetOptions(merge: true));

              Navigator.pop(context);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}
