import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../logic/cubit/user_profile_cubit.dart';
import '../data/models/user_profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _heightCtrl;
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    final state = context.read<UserProfileCubit>().state;
    if (state is UserProfileLoaded) {
      final profile = state.profile;
      _nameCtrl = TextEditingController(text: profile.name);
      _ageCtrl = TextEditingController(text: profile.age.toString());
      _weightCtrl = TextEditingController(text: profile.weight.toString());
      _heightCtrl = TextEditingController(text: profile.height.toString());
      _selectedGender = profile.gender;
    } else {
      _nameCtrl = TextEditingController();
      _ageCtrl = TextEditingController();
      _weightCtrl = TextEditingController();
      _heightCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() async {
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
      await context.read<UserProfileCubit>().saveProfile(profile);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocListener<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  autofocus: true,
                  validator: (val) => val == null || val.isEmpty ? 'Enter your name' : null,
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
                  validator: (val) => val == null || double.tryParse(val) == null ? 'Enter valid weight' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  validator: (val) => val == null || double.tryParse(val) == null ? 'Enter valid height' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _selectedGender = val!);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 