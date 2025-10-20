import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_buddy/views/auth/confirm_auth_view.dart';
import 'views/auth/auth_view.dart';
import 'views/home_view.dart';
import 'views/main_app_shell.dart';
import 'services/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  seedDefaultExercises();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Global Theme
      theme: ThemeData(
        // Background color for Scaffold
        scaffoldBackgroundColor: const Color.fromARGB(255, 5, 30, 77),

        // Default text style
        textTheme: GoogleFonts.fredokaTextTheme(
          // cleaner font
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),

        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.blue, // cursor color
          selectionColor: Colors.blueAccent, // text selection background
          selectionHandleColor: Colors.blue, // drag handles
        ),

        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue), // blue when focused
          ),
          labelStyle: TextStyle(color: Colors.white70), // label text color
        ),

        // ElevatedButton styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // TextButton styling
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 4, 22, 56),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      routes: {
        '/confirm-email': (context) => const ConfirmAuthView(),
        '/home': (context) => const HomeView(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          if (user != null) {
            // Reload user to get updated emailVerified status
            return FutureBuilder<User?>(
              future: user.reload().then(
                (_) => FirebaseAuth.instance.currentUser,
              ),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reloadedUser = userSnapshot.data;

                if (reloadedUser != null && reloadedUser.emailVerified) {
                  return const AppShell();
                } else {
                  return const ConfirmAuthView();
                }
              },
            );
          } else {
            return const AuthView();
          }
        },
      ),
    );
  }
}
