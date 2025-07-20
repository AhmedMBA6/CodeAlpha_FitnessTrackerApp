import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/activity_log_model.dart';
import '../../../activity_goals/data/models/activity_goal.dart';
import '../../../activity_goals/data/repositories/activity_goal_repository.dart';
import '../../data/repos/activity_log_repository.dart';
import '../../../../shared/widgets/progress_ring.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/utils/goal_progress_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../activity_goals/presentation/goals_screen.dart';
import 'activity_log_form_screen.dart';

// --- Cubit and State ---
class PostActivitySummaryState {
  final ActivityLogModel? log;
  final List<ActivityGoal> linkedGoals;
  final bool isLoading;
  final String? error;

  PostActivitySummaryState({
    this.log,
    this.linkedGoals = const [],
    this.isLoading = true,
    this.error,
  });

  PostActivitySummaryState copyWith({
    ActivityLogModel? log,
    List<ActivityGoal>? linkedGoals,
    bool? isLoading,
    String? error,
  }) {
    return PostActivitySummaryState(
      log: log ?? this.log,
      linkedGoals: linkedGoals ?? this.linkedGoals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PostActivitySummaryCubit extends Cubit<PostActivitySummaryState> {
  final int activityLogId;
  final ActivityLogRepository logRepository;
  final ActivityGoalRepository goalRepository;

  PostActivitySummaryCubit({
    required this.activityLogId,
    required this.logRepository,
    required this.goalRepository,
  }) : super(PostActivitySummaryState()) {
    _load();
  }

  Future<void> _load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final logs = await logRepository.getAllActivities();
      final log = logs.firstWhere((l) => l.id == activityLogId);
      final goals = await goalRepository.getAllGoals();
      final linkedGoals = goals.where((g) => log.linkedGoalIds?.contains(g.id) ?? false).toList();
      emit(state.copyWith(log: log, linkedGoals: linkedGoals, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }
}

// Helper to compute progress delta for a goal
  double _progressDelta(ActivityGoal goal, ActivityLogModel log) {
    final before = GoalProgressService.calculateGoalProgress(goal, []);
    final after = GoalProgressService.calculateGoalProgress(goal, [log]);
    return ((after.progress - before.progress) * 100).clamp(0, 100);
  }

// --- Screen ---
class PostActivitySummaryScreen extends StatelessWidget {
  final int activityLogId;
  const PostActivitySummaryScreen({super.key, required this.activityLogId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostActivitySummaryCubit(
        activityLogId: activityLogId,
        logRepository: GetIt.I<ActivityLogRepository>(),
        goalRepository: GetIt.I<ActivityGoalRepository>(),
      ),
      child: BlocBuilder<PostActivitySummaryCubit, PostActivitySummaryState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (state.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Activity Summary')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Couldn’t load log details', style: TextStyle(color: Colors.red, fontSize: 18)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back'),
                    ),
                  ],
                ),
              ),
            );
          }
          final log = state.log!;
          return Scaffold(
            appBar: AppBar(title: const Text('Activity Summary')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  // Recap
                  Text('Activity Recap', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${log.activityType}'),
                          Text('Duration: ${log.duration} min'),
                          Text('Distance: ${log.distance?.toStringAsFixed(2) ?? '-'} km'),
                          Text('Calories: ${log.calories.toStringAsFixed(1)}'),
                          Text('Tags: ${log.tags?.join(', ') ?? '-'}'),
                          Text('Date: ${log.date.toLocal()}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Goal Impact Cards
                  if (state.linkedGoals.isNotEmpty)
                    ...state.linkedGoals.map((goal) {
                      final progressResult = GoalProgressService.calculateGoalProgress(goal, [log]);
                      final progress = progressResult.progress;
                      final status = progressResult.status;
                      final delta = _progressDelta(goal, log);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              ProgressRing(progress: progress),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(goal.description ?? goal.id, style: Theme.of(context).textTheme.titleMedium),
                                        if (status == GoalStatus.completed)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Icon(Icons.emoji_events, color: Colors.amber, size: 24, semanticLabel: 'Goal Completed Badge'),
                                          ),
                                      ],
                                    ),
                                    Text('Progress: ${(progress * 100).toStringAsFixed(0)}%'),
                                    Text(status == GoalStatus.completed ? 'Completed!' : status.toString().split('.').last),
                                    if (delta > 0)
                                      Text('+${delta.toStringAsFixed(0)}% progress from this activity', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  if (state.linkedGoals.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              for (final goal in state.linkedGoals)
                                PieChartSectionData(
                                  value: log.calories, // For demo: all calories per goal
                                  title: goal.description ?? goal.id,
                                  color: Colors.primaries[state.linkedGoals.indexOf(goal) % Colors.primaries.length],
                                  radius: 60,
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 32,
                          ),
                        ),
                      ),
                    ),
                  if (state.linkedGoals.isEmpty)
                    const Text('No goals linked to this activity.'),
                  const SizedBox(height: 32),
                  // User Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => GoalsScreen()),
                            (route) => route.isFirst,
                          );
                        },
                        child: const Text('Back to Today’s Goals'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => ActivityLogFormScreen()),
                            (route) => route.isFirst,
                          );
                        },
                        child: const Text('Log Another Activity'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 