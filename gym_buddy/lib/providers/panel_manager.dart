import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PanelManager with ChangeNotifier {
  final PanelController panelController = PanelController();

  void openPanel() {
    panelController.open();
  }

  void closePanel() {
    panelController.close();
  }

  void togglePanel() async {
    if (panelController.isPanelOpen) {
      panelController.close();
    } else {
      panelController.open();
    }
  }
}
