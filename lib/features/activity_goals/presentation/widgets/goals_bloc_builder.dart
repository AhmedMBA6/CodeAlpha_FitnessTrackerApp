import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/goals_cubit.dart';
import '../../logic/cubit/goals_state.dart';

/// A reusable BlocBuilder for the Goals feature.
/// Usage: GoalsBlocBuilder(builder: (context, state) { ... })
class GoalsBlocBuilder extends StatelessWidget {
  final BlocWidgetBuilder<GoalsState> builder;
  const GoalsBlocBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalsCubit, GoalsState>(
      builder: builder,
    );
  }
} 