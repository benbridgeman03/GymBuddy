import 'package:flutter/material.dart';
import 'home_view.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const Center(child: Text("Excersizes Page")), // placeholder for now
    const Center(child: Text("History Page")), // placeholder for now
    const Center(child: Text("Profile Page")), // placeholder for now
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color.fromARGB(255, 56, 60, 116),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Start Workout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Excersises",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: "History",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
