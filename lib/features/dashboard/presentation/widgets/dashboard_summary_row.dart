import 'package:flutter/material.dart';
import '../../data/dashboard_aggregator.dart';
import '../../../../core/constants/dashboard_constants.dart';

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
              child: _SummaryCard(
                label: 'Calories Burned',
                value: today.totalCalories.toStringAsFixed(0),
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                label: 'Duration (min)',
                value: today.totalDuration.toString(),
                icon: Icons.timer,
                color: Colors.blue,
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
              child: _SummaryCard(
                label: 'Total Activities',
                value: metrics.totalActivities.toString(),
                icon: Icons.fitness_center,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                label: 'Avg Duration (min)',
                value: metrics.averageDuration.toStringAsFixed(0),
                icon: Icons.av_timer,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Total Calories',
                value: metrics.totalCalories.toStringAsFixed(0),
                icon: Icons.local_fire_department,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                label: 'Avg Calories/Activity',
                value: metrics.averageCaloriesPerActivity.toStringAsFixed(0),
                icon: Icons.trending_up,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: DashboardConstants.cardElevation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: DashboardConstants.iconSize),
            const SizedBox(height: 6),
            Text(
              value, 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label, 
              style: const TextStyle(fontSize: 10), 
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 