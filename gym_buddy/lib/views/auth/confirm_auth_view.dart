// lib/view/confirm_email_view.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfirmAuthView extends StatefulWidget {
  const ConfirmAuthView({super.key});

  @override
  State<ConfirmAuthView> createState() => _ConfirmAuthViewState();
}

class _ConfirmAuthViewState extends State<ConfirmAuthView> {
  bool isVerified = false;
  bool isLoading = false;

  // Reload user to check verification status
  Future<void> checkEmailVerified() async {
    setState(() => isLoading = true);
    await FirebaseAuth.instance.currentUser!.reload();
    final user = FirebaseAuth.instance.currentUser!;
    if (user.emailVerified) {
      setState(() => isVerified = true);
    }
    setState(() => isLoading = false);
  }

  Future<void> resendVerification() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification email resent!')));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // get current user

    if (isVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm your email')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user != null
                    ? 'A verification email has been sent to ${user.email}.\nPlease check your inbox and click the link.'
                    : 'A verification email has been sent.\nPlease check your inbox and click the link.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: checkEmailVerified,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('I have verified'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: resendVerification,
                child: const Text('Resend verification email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
