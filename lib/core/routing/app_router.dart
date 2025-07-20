import 'dart:io';

import 'package:codealpha_fitness_tracker_app/core/routing/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/activity_log/logic/activity_log_cubit.dart';
import '../../features/activity_log/presentation/activity_log_list_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/logic/dashboard_cubit.dart';
import '../../features/activity_goals/presentation/goals_screen.dart';
import '../../features/activity_goals/logic/cubit/goals_cubit.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/activity_log/data/repos/activity_log_goal_link_repository.dart';
import '../../features/activity_goals/data/repositories/activity_goal_repository.dart';
import '../../features/activity_log/data/repos/activity_log_repository.dart';
import '../../features/auth/presentation/login/login_screen.dart';
import '../../features/auth/presentation/signup/signup_screen.dart';
import '../../features/user_profile/presentation/complete_profile_screen.dart';
import '../../features/user_profile/logic/cubit/user_profile_cubit.dart';

/// Handles route generation for the app, mapping route names to screens and providing
/// dependency injection for feature entry points.
class AppRouter {
  /// Generates a [Route] based on the given [RouteSettings].
  /// Handles all named routes defined in [Routes].
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Widget screen;

    switch (settings.name) {
      case Routes.login:
        screen = const LoginScreen();
        break;
      case Routes.signup:
        screen = const SignupScreen();
        break;
      case Routes.completeProfile:
        screen = BlocProvider(
          create: (_) => UserProfileCubit(),
          child: const CompleteProfileScreen(),
        );
        break;
      case Routes.homeScreen:
        screen = HomeScreen();
        break;
      case Routes.activityLogList:
        screen = BlocProvider(
          create: (_) => ActivityLogListCubit(
            linkRepository: SQLiteActivityLogGoalLinkRepository(),
          )..loadActivities(),
          child: ActivityLogListScreen(),
        );
        break;
      case Routes.dashboard:
        screen = BlocProvider(
          create: (_) => DashboardCubit()..loadDashboard(),
          child: DashboardScreen(),
        );
        break;
      case Routes.goals:
        screen = BlocProvider(
          create: (_) => GoalsCubit(
            goalRepo: ActivityGoalRepository(),
            linkRepo: SQLiteActivityLogGoalLinkRepository(),
            activityLogRepo: ActivityLogRepository(linkRepo: SQLiteActivityLogGoalLinkRepository()),
          ),
          child: GoalsScreen(),
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
