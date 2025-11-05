import 'package:flutter/material.dart';
import 'package:gym_buddy/models/set_type.dart';
import 'package:gym_buddy/models/workout_template.dart';
import 'package:gym_buddy/providers/panel_manager.dart';
import 'package:gym_buddy/providers/workout_manager.dart';
import 'package:gym_buddy/views/template_view.dart';
import 'package:provider/provider.dart';

class WorkoutTemplateTile extends StatefulWidget {
  final WorkoutTemplate template;

  const WorkoutTemplateTile({Key? key, required this.template})
    : super(key: key);

  @override
  State<WorkoutTemplateTile> createState() => _WorkoutTemplateTileState();
}

class _WorkoutTemplateTileState extends State<WorkoutTemplateTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final template = widget.template;

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 8, 28, 70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          title: Text(
            template.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white70,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < template.exercises.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: i == template.exercises.length - 1
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  template.exercises[i].exercise.name,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '× ${template.exercises[i].sets.where((ex) => ex.setType != SetType.warmup).length}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            if (i == template.exercises.length - 1)
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: Colors.white,
                                  overlayColor: Colors.white24,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(4),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TemplateView(
                                        existingTemplate: template,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 15,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<WorkoutManager>().start();
                      context.read<PanelManager>().openWithTemplate(template);
                    },
                    child: const Text('Start Workout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
