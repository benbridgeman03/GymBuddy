// lib/view/auth_view.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isLogin = true;
  String? errorMessage;

  void _submit() async {
    try {
      // Check password confirmation
      if (!isLogin &&
          _passwordController.text != _confirmPasswordController.text) {
        setState(() => errorMessage = 'Passwords do not match');
        return;
      }

      if (isLogin) {
        final user = await _auth.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (user != null && !user.emailVerified) {
          // Sign out and go to confirm email page
          await _auth.signOut();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/confirm-email');
          }
          return;
        }

        // Email verified → go to home
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Sign up flow
        final user = await _auth.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (user != null) {
          // Email verification is already sent in signUp()
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/confirm-email');
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLogin ? 'Login' : 'Sign Up',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (!isLogin)
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: Text(isLogin ? 'Login' : 'Sign Up'),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(
                isLogin ? 'Need an account? Sign up' : 'Have an account? Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
