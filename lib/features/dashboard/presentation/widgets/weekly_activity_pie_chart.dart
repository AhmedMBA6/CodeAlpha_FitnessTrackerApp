import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../activity_log/data/models/activity_log_model.dart';
import '../../../../core/constants/dashboard_constants.dart';

class WeeklyActivityPieChart extends StatelessWidget {
  final List<ActivityLogModel> activityLogs;
  
  const WeeklyActivityPieChart({
    required this.activityLogs,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final activityTypeTotals = _calculateActivityTypeTotals();
    final total = activityTypeTotals.values.fold<double>(0, (a, b) => a + b);
    
    return Container(
      height: DashboardConstants.chartHeight,
      child: activityTypeTotals.isEmpty
          ? const Center(child: Text('No activity data'))
          : PieChart(
              PieChartData(
                sections: _buildPieSections(activityTypeTotals, total),
                sectionsSpace: 2,
                centerSpaceRadius: DashboardConstants.centerSpaceRadius,
              ),
            ),
    );
  }

  Map<String, double> _calculateActivityTypeTotals() {
    final Map<String, double> activityTypeTotals = {};
    for (final log in activityLogs) {
      activityTypeTotals[log.activityType] =
          (activityTypeTotals[log.activityType] ?? 0) + 1;
    }
    return activityTypeTotals;
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> activityTypeTotals,
    double total,
  ) {
    return List.generate(activityTypeTotals.length, (i) {
      final entry = activityTypeTotals.entries.elementAt(i);
      final percent = total == 0 ? 0 : (entry.value / total * 100);
      final color = Color(DashboardConstants.chartColors[i % DashboardConstants.chartColors.length]);
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key}\n${percent.toStringAsFixed(0)}%',
        radius: DashboardConstants.chartRadius,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
} 