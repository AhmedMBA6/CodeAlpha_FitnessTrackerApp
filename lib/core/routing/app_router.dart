import 'dart:io';

import 'package:codealpha_fitness_tracker_app/main.dart';
import 'package:codealpha_fitness_tracker_app/core/routing/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/login/login_screen.dart';
import '../../features/auth/presentation/signup/signup_screen.dart';
import '../../features/user_profile/data/repos/user_profile_repository.dart';
import '../../features/user_profile/logic/cubit/user_profile_cubit.dart';
import '../../features/user_profile/presentation/complete_profile_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Widget screen;

    switch (settings.name) {
      case Routes.loginScreen:
        screen = LoginScreen();
        break;
      case Routes.signupScreen:
        screen = SignupScreen();
        break;
      case Routes.homeScreen:
        screen = MyHomePage(title: "Fitness Tracker");
        break;
      case Routes.completeProfile:
        screen = BlocProvider(
          create: (_) => UserProfileCubit(UserProfileRepository()),
          child: CompleteProfileScreen(),
        );
        break;
      default:
        screen = const Scaffold(body: Center(child: Text('Page not found')));
    }

    return Platform.isIOS
        ? CupertinoPageRoute(builder: (context) => screen, settings: settings)
        : MaterialPageRoute(builder: (context) => screen, settings: settings);
  }
}
