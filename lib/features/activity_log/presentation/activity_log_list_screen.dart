import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/activity_log_cubit.dart';
import '../data/models/activity_log_model.dart';
import 'widgets/activity_log_form.dart';

class ActivityLogListScreen extends StatelessWidget {
  const ActivityLogListScreen({super.key});

  void _showForm(BuildContext context, {ActivityLogModel? log}) {
    final cubit = context.read<ActivityLogCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: ActivityLogForm(
            initialLog: log,
            onSaved: () {
              Navigator.of(ctx).pop();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Log')),
      body: BlocBuilder<ActivityLogCubit, ActivityLogState>(
        builder: (context, state) {
          if (state is ActivityLogLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ActivityLogSuccess) {
            final activities = state.activities;
            if (activities.isEmpty) {
              return const Center(child: Text('No activities logged yet.'));
            }
            return ListView.separated(
              itemCount: activities.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final log = activities[i];
                return ListTile(
                  title: Text(log.activityType),
                  subtitle: Text(
                    'Duration: ${log.duration} min\nCalories: ${log.calories}\nDate: ${log.date.toLocal().toIso8601String().split('T').first}' +
                    (log.heartRate != null ? '\nHeart Rate: ${log.heartRate}' : '') +
                    (log.distance != null ? '\nDistance: ${log.distance} km' : ''),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showForm(context, log: log),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => context.read<ActivityLogCubit>().deleteActivity(log.id!),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is ActivityLogError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: Builder(
        builder: (fabContext) => FloatingActionButton(
          onPressed: () => _showForm(fabContext),
          child: const Icon(Icons.add),
          tooltip: 'Add Activity',
        ),
      ),
    );
  }
} 