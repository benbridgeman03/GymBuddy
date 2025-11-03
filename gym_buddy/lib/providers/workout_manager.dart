import 'dart:async';
import 'package:flutter/material.dart';

class WorkoutManager extends ChangeNotifier {
  final Stopwatch elapsedTime = Stopwatch();
  DateTime? startedAt;
  Timer? _timer;
  bool isRunning = false;

  void start() {
    if (isRunning) return;
    isRunning = true;
    startedAt = DateTime.now();
    elapsedTime.start();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => notifyListeners());
  }

  void stop() {
    isRunning = false;
    startedAt = null;
    elapsedTime.stop();
    _timer?.cancel();
    notifyListeners();
  }

  void reset() {
    elapsedTime.stop();

    _timer?.cancel();
    _timer = null;

    elapsedTime.reset();

    isRunning = false;
    startedAt = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
