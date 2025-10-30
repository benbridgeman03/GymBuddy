import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/panel_manager.dart';

class WorkoutView extends StatefulWidget {
  const WorkoutView({super.key});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  @override
  Widget build(BuildContext context) {
    final panelManager = Provider.of<PanelManager>(context, listen: false);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grab handle
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
