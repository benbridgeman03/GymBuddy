import 'package:flutter/material.dart';
import 'package:gym_buddy/models/wokrout_template.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PanelManager with ChangeNotifier {
  final PanelController panelController = PanelController();

  WorkoutTemplate? _activeTemplate;
  WorkoutTemplate? get activeTemplate => _activeTemplate;

  void openWithTemplate(WorkoutTemplate template) {
    _activeTemplate = template;
    notifyListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      panelController.open();
    });
  }

  void openPanel() {
    panelController.open();
  }

  void clearTemplate() {
    _activeTemplate = null;
    notifyListeners();
  }

  void closePanel() {
    _activeTemplate = null;
    panelController.close();
    notifyListeners();
  }

  void togglePanel() async {
    if (panelController.isPanelOpen) {
      closePanel();
    } else {
      panelController.open();
    }
  }
}
