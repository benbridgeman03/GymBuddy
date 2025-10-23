import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise.dart';

class ExerciseProvider extends ChangeNotifier {
  final List<Exercise> _exercises = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<Exercise> get exercises => _exercises;
  bool get isLoading => _isLoading;

  /// Start listening to the user's exercise collection
  Future<void> init() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .orderBy('name')
        .snapshots()
        .listen((snapshot) {
          _exercises
            ..clear()
            ..addAll(snapshot.docs.map((doc) => Exercise.fromDoc(doc)));
          _isLoading = false;
          notifyListeners();
        });
  }

  /// Dispose listener when not needed
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
