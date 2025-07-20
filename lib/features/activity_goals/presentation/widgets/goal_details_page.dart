// TODO: Ensure theming, accessibility, and navigation best practices are followed in this widget.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../activity_goals/logic/cubit/goal_details_cubit.dart';
import '../../../activity_goals/data/repositories/activity_goal_repository.dart';
import '../../../activity_log/data/repos/activity_log_repository.dart';
import '../../../activity_log/data/models/activity_log_model.dart';
import '../../../activity_goals/data/models/activity_goal.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../../../shared/widgets/goal_chip.dart';
import 'package:get_it/get_it.dart';
import '../../../activity_log/presentation/widgets/activity_log_details_page.dart';

class GoalDetailsPage extends StatelessWidget {
  final String goalId;

  const GoalDetailsPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GoalDetailsCubit(
        goalRepository: GetIt.I<ActivityGoalRepository>(),
        logRepository: GetIt.I<ActivityLogRepository>(),
      )..loadGoalDetails(goalId),
      child: BlocBuilder<GoalDetailsCubit, GoalDetailsState>(
        builder: (context, state) {
          if (state is GoalDetailsLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is GoalDetailsLoaded) {
            final ActivityGoal goal = state.goal;
            final List<ActivityLogModel> activities = state.linkedActivities;
            return Scaffold(
              appBar: AppBar(title: Text(goal.description ?? 'Goal Details')),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(goal.description ?? '', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  GoalChip(label: goal.goalType.name, completed: goal.isCompleted ?? false),
                  const SizedBox(height: 16),
                  ProgressRing(progress: goal.progress ?? 0.0),
                  const SizedBox(height: 16),
                  Text('Created: ${goal.createdAt.toLocal().toString().split(' ').first}', style: Theme.of(context).textTheme.bodyMedium),
                  if (goal.goalType == GoalType.quantitative)
                    Text('Target: ${goal.targetValue?.toStringAsFixed(0) ?? '-'} ${goal.unit ?? ''}', style: Theme.of(context).textTheme.bodyMedium),
                  if (goal.goalType == GoalType.qualitative)
                    Text('Tags: ${goal.tags?.join(', ') ?? '-'}', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  Text('Linked Activities', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (activities.isEmpty)
                    Text('No activities linked yet.', style: Theme.of(context).textTheme.bodyMedium),
                  ...activities.map((a) => ListTile(
                        title: Text(a.activityType),
                        subtitle: Text('${a.duration} min, ${a.distance ?? '-'} km'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ActivityLogDetailsPage(activityLogId: a.id!),
                          ));
                        },
                      )),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Edit goal
                        },
                        child: const Text('Edit', maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Delete goal
                        },
                        child: const Text('Delete', maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is GoalDetailsError) {
            return Scaffold(
              body: Center(child: Text('Error: ${state.message}')),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
} 