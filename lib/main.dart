import 'package:codealpha_fitness_tracker_app/firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';

import 'package:codealpha_fitness_tracker_app/core/utils/di.dart';
import 'core/routing/app_router.dart';

import 'features/home/presentation/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/data/authentication_repository.dart';
import 'features/auth/logic/auth_state.dart';
import 'features/auth/presentation/login/login_screen.dart';
import 'features/user_profile/logic/cubit/user_profile_cubit.dart';
import 'features/user_profile/presentation/complete_profile_screen.dart';

/// The main entry point for the Fitness Tracker app.
///
/// Initializes Firebase and runs the root [MyApp] widget.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('DEBUG: Before Firebase.initializeApp');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('DEBUG: After Firebase.initializeApp');
  setupDependencies();
  print('DEBUG: After setupDependencies');
  
  runApp(const MyApp());
  print('DEBUG: After runApp');
}

/// Wrapper widget that handles authentication state and shows appropriate screens.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // User is not authenticated, navigate to login
          Navigator.of(context).pushReplacementNamed('/login');
        } else if (state is AuthSuccess) {
          // User is authenticated, navigate to home
          Navigator.of(context).pushReplacementNamed('/homeScreen');
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is AuthSuccess && !state.isNewUser) {
            // Show home screen for existing authenticated users
            return const HomeScreen();
          } else if (state is AuthSuccess && state.isNewUser) {
            // Show complete profile for new users
            return BlocProvider(
              create: (_) => UserProfileCubit(),
              child: const CompleteProfileScreen(),
            );
          } else {
            // Show login screen for unauthenticated users
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

/// The root widget of the Fitness Tracker app.
///
/// Sets up global providers and configures the app's theme and routing.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(getIt<AuthenticationRepository>()),
        ),
        // Add other global cubits here if needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fitness Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('es', ''), // Spanish
          Locale('fr', ''), // French
        ],
        home: const AuthWrapper(),
        onGenerateRoute: AppRouter.generateRoute,
        // Remove initialRoute, onGenerateRoute, and any routes map for now
      ),
    );
  }
}
