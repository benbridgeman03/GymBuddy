import 'package:flutter/material.dart';
import 'home_view.dart';
import 'exercises_view.dart';
import '/views/workout_view.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '/providers/panel_manager.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const ExcersizesView(),
    const Center(child: Text("History Page")), // placeholder for now
    const Center(child: Text("Profile Page")), // placeholder for now
  ];

  Widget build(BuildContext context) {
    final panelManager = Provider.of<PanelManager>(context);

    return Stack(
      children: [
        Scaffold(
          body: _pages[_currentIndex],
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: const Color.fromARGB(255, 28, 34, 59),
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.white,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: "Start Workout",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center),
                  label: "Exercises",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.access_time),
                  label: "History",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: SlidingUpPanel(
            controller: panelManager.panelController,
            minHeight: 0,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            backdropEnabled: true,
            backdropTapClosesPanel: true,
            panelSnapping: true,
            panel: const WorkoutView(),
          ),
        ),
      ],
    );
  }
}
