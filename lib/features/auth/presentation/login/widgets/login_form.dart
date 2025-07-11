import 'package:codealpha_fitness_tracker_app/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth_cubit.dart';
import '../../../logic/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submitLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().emitLoginState(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthSuccess) {
          if (state.isNewUser) {
            Navigator.pushReplacementNamed(context, Routes.completeProfile);
          } else {
            Navigator.pushReplacementNamed(context, Routes.homeScreen);
          }
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter your email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (val) => val == null || val.length < 6
                    ? 'Enter a valid password'
                    : null,
              ),
              const SizedBox(height: 24),
              state is AuthLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _submitLogin(context),
                      child: const Text("Login"),
                    ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.signupScreen);
                },
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        );
      },
    );
  }
}
