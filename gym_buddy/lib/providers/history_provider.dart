import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_buddy/models/workout_log.dart';
import '../models/exercise.dart';

class HistoryProvider extends ChangeNotifier {
  final List<WorkoutSession> _workouts = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<WorkoutSession> get workouts => _workouts;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    print("init history");
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .orderBy('startedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          print("Received ${snapshot.docs.length} workouts");
          _workouts
            ..clear()
            ..addAll(snapshot.docs.map((doc) => WorkoutSession.fromDoc(doc)));
          _isLoading = false;
          notifyListeners();
        });
  }

  void clear() {
    _subscription?.cancel();
    _subscription = null;
    _workouts.clear();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
