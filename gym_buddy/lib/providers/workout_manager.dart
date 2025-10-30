import 'dart:async';
import 'package:flutter/material.dart';

class WorkoutManager extends ChangeNotifier {
  final Stopwatch elapsedTime = Stopwatch();
  Timer? _timer;
  bool isRunning = false;

  void start() {
    if (isRunning) return;
    isRunning = true;
    elapsedTime.start();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => notifyListeners());
  }

  void stop() {
    isRunning = false;
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

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
