import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise.dart';

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
                        // TODO: Add exercise
                      },
                      icon: const Icon(Icons.add),
                      color: Colors.white,
                      iconSize: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Expanded(
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
                              (ex) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(ex.name),
                                textColor: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
