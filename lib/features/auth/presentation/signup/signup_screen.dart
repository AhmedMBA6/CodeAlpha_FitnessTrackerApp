import 'package:flutter/material.dart';
import 'widgets/signup_form.dart';

/// Screen for user signup.
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: SignupForm(),
        ),
      ),
    );
  }
}
