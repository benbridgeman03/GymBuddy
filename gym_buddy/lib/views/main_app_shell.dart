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
    const Center(child: Text("Exercises Page")), // placeholder for now
    const Center(child: Text("History Page")), // placeholder for now
    const Center(child: Text("Profile Page")), // placeholder for now
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, // disables the white ripple
          highlightColor: Colors.transparent, // removes highlight on tap
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
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
