import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/user_profile_cubit.dart';
import '../../data/models/user_profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/routing/routes.dart';

/// Form widget for completing user profile after signup.
class CompleteProfileForm extends StatefulWidget {
  const CompleteProfileForm({super.key});

  @override
  State<CompleteProfileForm> createState() => _CompleteProfileFormState();
}

/// State for [CompleteProfileForm]. Handles form logic and submission.
class _CompleteProfileFormState extends State<CompleteProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  String _selectedGender = 'Male';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _submitProfile(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final profile = UserProfileModel(
        uid: user.uid,
        name: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text.trim()),
        weight: double.parse(_weightCtrl.text.trim()),
        height: double.parse(_heightCtrl.text.trim()),
        gender: _selectedGender,
      );

      context.read<UserProfileCubit>().saveProfile(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileCubit, UserProfileState>(
      listener: (context, state) {
        if (state is UserProfileSuccess) {
          Navigator.pushReplacementNamed(context, Routes.homeScreen);
        } else if (state is UserProfileError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter age';
                  final age = int.tryParse(val);
                  return (age == null || age < 10) ? 'Invalid age' : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                validator: (val) => val == null || double.tryParse(val) == null
                    ? 'Enter valid weight'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                validator: (val) => val == null || double.tryParse(val) == null
                    ? 'Enter valid height'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              state is UserProfileLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => _submitProfile(context),
                      child: const Text('Complete Profile'),
                    ),
            ],
          ),
        );
      },
    );
  }
}
