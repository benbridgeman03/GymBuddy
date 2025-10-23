import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_buddy/views/auth/confirm_auth_view.dart';
import 'views/auth/auth_view.dart';
import 'views/main_app_shell.dart';
import 'views/template_view.dart';
import 'package:provider/provider.dart';
import 'providers/exercise_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExerciseProvider()..init()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Global Theme
      theme: ThemeData(
        // Background color for Scaffold
        scaffoldBackgroundColor: const Color.fromARGB(255, 15, 23, 42),

        // Default text style
        textTheme: GoogleFonts.robotoTextTheme(
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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

        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF0A1A3A), // dark blue-ish background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // rounded corners
          ),
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          contentTextStyle: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ),

      routes: {
        '/confirm-email': (context) => const ConfirmAuthView(),
        '/template': (context) => const TemplateView(),
        '/home': (context) => const AppShell(),
      },
      
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          if (user != null) {
            // User exists
            if (user.emailVerified) {
              return const AppShell(); // verified → go home
            } else {
              return const ConfirmAuthView(); // unverified → confirm email
            }
          } else {
            // No user → show login/signup page
            return const AuthView();
          }
        },
      ),
    );
  }
}
