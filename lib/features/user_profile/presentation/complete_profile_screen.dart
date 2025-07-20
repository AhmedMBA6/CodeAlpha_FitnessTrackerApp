import 'package:flutter/material.dart';
import 'widgets/complete_profile_form.dart';

/// Screen for completing the user's profile after signup.
class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CompleteProfileForm(),
        ),
      ),
    );
  }
}
