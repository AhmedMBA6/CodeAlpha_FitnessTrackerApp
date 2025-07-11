import 'package:flutter/material.dart';
import 'widgets/complete_profile_form.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text("Complete Your Profile")),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: CompleteProfileForm(),
      ),
    );
  }
}
