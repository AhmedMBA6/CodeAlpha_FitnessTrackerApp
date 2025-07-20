import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/activity_log_model.dart';
import '../../../activity_goals/data/models/activity_goal.dart';
import '../../../activity_goals/data/repositories/activity_goal_repository.dart';
import '../../data/repos/activity_log_repository.dart';
import '../../../../shared/widgets/goal_chip.dart';
import 'package:get_it/get_it.dart';
import '../../../activity_goals/presentation/widgets/goal_details_page.dart';
import 'activity_log_form_screen.dart';
import '../../data/repos/activity_log_goal_link_repository.dart';

class ActivityLogDetailsCubit extends Cubit<ActivityLogModel?> {
  final String activityLogId;
  final ActivityLogRepository logRepository;
  final ActivityGoalRepository goalRepository;
  List<ActivityGoal> linkedGoals = [];

  ActivityLogDetailsCubit({
    required this.activityLogId,
    required this.logRepository,
    required this.goalRepository,
  }) : super(null) {
    _load();
  }

  Future<void> _load() async {
    final logs = await logRepository.getAllActivities();
    final log = logs.firstWhere((l) => l.id == activityLogId);
    final goals = await goalRepository.getAllGoals();
    linkedGoals = goals.where((g) => log.linkedGoalIds?.contains(g.id) ?? false).toList();
    emit(log);
  }
}

class ActivityLogDetailsPage extends StatelessWidget {
  final String activityLogId;
  const ActivityLogDetailsPage({super.key, required this.activityLogId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActivityLogDetailsCubit(
        activityLogId: activityLogId,
        logRepository: GetIt.I<ActivityLogRepository>(),
        goalRepository: GetIt.I<ActivityGoalRepository>(),
      ),
      child: BlocBuilder<ActivityLogDetailsCubit, ActivityLogModel?>(
        builder: (context, log) {
          final cubit = context.read<ActivityLogDetailsCubit>();
          if (log == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Activity Details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Activity',
                  onPressed: () async {
                    // Fetch linked goals for the log
                    final linkRepo = SQLiteActivityLogGoalLinkRepository();
                    final goalRepo = ActivityGoalRepository();
                    final links = await linkRepo.getLinksForActivityLog(log.id.toString());
                    final goalIds = links.map((l) => l.goalId).toSet();
                    final allGoals = await goalRepo.getAllGoals();
                    final linkedGoals = allGoals.where((g) => goalIds.contains(g.id)).toList();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (ctx) => ActivityLogFormScreen(
                          initialLog: log,
                          initialGoals: linkedGoals,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Home > Activities > Log #${log.id ?? ''}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey),
                    ),
                  ),
                  Text('Type: ${log.activityType}', style: Theme.of(context).textTheme.titleLarge),
                  Text('Duration: ${log.duration} min'),
                  Text('Distance: ${log.distance?.toStringAsFixed(2) ?? '-'} km'),
                  Text('Calories: ${log.calories.toStringAsFixed(1)}'),
                  Text('Tags: ${log.tags?.join(', ') ?? '-'}'),
                  Text('Date: ${log.date.toLocal()}'),
                  const SizedBox(height: 24),
                  Text('Linked Goals', style: Theme.of(context).textTheme.titleMedium),
                  if (cubit.linkedGoals.isEmpty)
                    const Text('No goals linked.'),
                  if (cubit.linkedGoals.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: cubit.linkedGoals.map((goal) => GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => GoalDetailsPage(goalId: goal.id),
                          ));
                        },
                        child: GoalChip(label: goal.description ?? goal.id, completed: goal.isCompleted ?? false),
                      )).toList(),
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