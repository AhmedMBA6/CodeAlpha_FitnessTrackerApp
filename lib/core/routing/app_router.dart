import 'dart:io';

import 'package:codealpha_fitness_tracker_app/main.dart';
import 'package:codealpha_fitness_tracker_app/core/routing/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/login/login_screen.dart';
import '../../features/auth/presentation/signup/signup_screen.dart';

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
        screen = MyHomePage(title: "Fitness Tracker",);
        break;
      default:
        screen = const Scaffold(
          body: Center(
            child: Text('Page not found'),
          ),
        );
    }

    return Platform.isIOS
        ? CupertinoPageRoute(
            builder: (context) => screen,
            settings: settings,
          )
        : MaterialPageRoute(
            builder: (context) => screen,
            settings: settings,
          );
  }
}