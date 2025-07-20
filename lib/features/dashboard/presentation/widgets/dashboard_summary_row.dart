import 'package:flutter/material.dart';
import '../../data/dashboard_aggregator.dart';
import 'package:codealpha_fitness_tracker_app/shared/widgets/summary_card.dart';

class DashboardSummaryRow extends StatelessWidget {
  final DashboardSummary today;
  final DashboardMetrics metrics;
  
  const DashboardSummaryRow({
    required this.today,
    required this.metrics,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Today's summary
        const Text('Today\'s Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Tooltip(
                message: 'Calories burned today',
                child: Semantics(
                  label: 'Calories burned today: ${today.totalCalories.toStringAsFixed(0)}',
                  child: SummaryCard(
                    label: 'Calories Burned',
                    value: today.totalCalories.toStringAsFixed(0),
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Tooltip(
                message: 'Duration of activities today in minutes',
                child: Semantics(
                  label: 'Duration today: ${today.totalDuration} minutes',
                  child: SummaryCard(
                    label: 'Duration (min)',
                    value: today.totalDuration.toString(),
                    icon: Icons.timer,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Overall metrics
        const Text('Overall Metrics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Tooltip(
                message: 'Total activities logged',
                child: Semantics(
                  label: 'Total activities: ${metrics.totalActivities}',
                  child: SummaryCard(
                    label: 'Total Activities',
                    value: metrics.totalActivities.toString(),
                    icon: Icons.fitness_center,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Tooltip(
                message: 'Average duration per activity in minutes',
                child: Semantics(
                  label: 'Average duration per activity: ${metrics.averageDuration.toStringAsFixed(0)} minutes',
                  child: SummaryCard(
                    label: 'Avg Duration (min)',
                    value: metrics.averageDuration.toStringAsFixed(0),
                    icon: Icons.av_timer,
                    color: Colors.purple,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Tooltip(
                message: 'Total calories burned',
                child: Semantics(
                  label: 'Total calories burned: ${metrics.totalCalories.toStringAsFixed(0)}',
                  child: SummaryCard(
                    label: 'Total Calories',
                    value: metrics.totalCalories.toStringAsFixed(0),
                    icon: Icons.local_fire_department,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Tooltip(
                message: 'Average calories burned per activity',
                child: Semantics(
                  label: 'Average calories per activity: ${metrics.averageCaloriesPerActivity.toStringAsFixed(0)}',
                  child: SummaryCard(
                    label: 'Avg Calories/Activity',
                    value: metrics.averageCaloriesPerActivity.toStringAsFixed(0),
                    icon: Icons.trending_up,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 