import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../activity_log/data/models/activity_log_model.dart';
import '../../data/dashboard_aggregator.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../core/constants/dashboard_constants.dart';

class DashboardExport extends StatelessWidget {
  final DashboardMetrics metrics;
  final List<ActivityLogModel> activityLogs;
  final DateTime? startDate;
  final DateTime? endDate;

  const DashboardExport({
    super.key,
    required this.metrics,
    required this.activityLogs,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export & Share', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportAsText(context),
                    icon: const Icon(Icons.text_snippet),
                    label: const Text('Export as Text'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareSummary(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Share Summary'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyToClipboard(context),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy to Clipboard'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDetailedReport(context),
                    icon: const Icon(Icons.assessment),
                    label: const Text('Detailed Report'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportAsText(BuildContext context) {
    final report = _generateReport();
    _showExportDialog(context, 'Dashboard Report', report);
  }

  void _shareSummary(BuildContext context) {
    final summary = _generateSummary();
    _showExportDialog(context, 'Fitness Summary', summary);
  }

  void _copyToClipboard(BuildContext context) {
    final summary = _generateSummary();
    Clipboard.setData(ClipboardData(text: summary));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary copied to clipboard')),
    );
  }

  void _showDetailedReport(BuildContext context) {
    final report = _generateDetailedReport();
    _showExportDialog(context, 'Detailed Fitness Report', report);
  }

  void _showExportDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: SelectableText(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  String _generateSummary() {
    final dateRange = _formatDateRange();
    return '''
🏃‍♂️ Fitness Summary $dateRange

📊 Key Metrics:
• Total Activities: ${metrics.totalActivities}
• Total Calories: ${metrics.totalCalories.toStringAsFixed(0)}
• Total Duration: ${metrics.totalDuration} minutes
• Average Duration: ${metrics.averageDuration.toStringAsFixed(0)} minutes
• Average Calories per Activity: ${metrics.averageCaloriesPerActivity.toStringAsFixed(0)}

🎯 Activity Breakdown:
${_formatActivityBreakdown()}

Keep up the great work! 💪
''';
  }

  String _generateReport() {
    final dateRange = _formatDateRange();
    return '''
FITNESS TRACKER DASHBOARD REPORT
Generated on: ${app_date_utils.DateUtils.formatDateForExport(DateTime.now())}
Date Range: $dateRange

SUMMARY METRICS:
================
Total Activities: ${metrics.totalActivities}
Total Calories Burned: ${metrics.totalCalories.toStringAsFixed(0)}
Total Duration: ${metrics.totalDuration} minutes
Average Duration per Activity: ${metrics.averageDuration.toStringAsFixed(0)} minutes
Average Calories per Activity: ${metrics.averageCaloriesPerActivity.toStringAsFixed(0)}

ACTIVITY TYPE BREAKDOWN:
=======================
${_formatActivityBreakdownDetailed()}

RECENT ACTIVITIES:
=================
${_formatRecentActivities()}
''';
  }

  String _generateDetailedReport() {
    final dateRange = _formatDateRange();
    return '''
DETAILED FITNESS REPORT
=======================
Generated: ${DateTime.now().toString()}
Period: $dateRange

OVERVIEW:
=========
Total Activities: ${metrics.totalActivities}
Total Calories: ${metrics.totalCalories.toStringAsFixed(0)}
Total Duration: ${metrics.totalDuration} minutes
Average Duration: ${metrics.averageDuration.toStringAsFixed(0)} minutes
Average Calories per Activity: ${metrics.averageCaloriesPerActivity.toStringAsFixed(0)}

ACTIVITY BREAKDOWN:
==================
${_formatActivityBreakdownDetailed()}

ACTIVITY LOG:
=============
${_formatActivityLog()}

PERFORMANCE ANALYSIS:
====================
${_generatePerformanceAnalysis()}
''';
  }

  String _formatDateRange() {
    return app_date_utils.DateUtils.formatDateRange(startDate, endDate);
  }

  String _formatActivityBreakdown() {
    if (metrics.activityTypeBreakdown.isEmpty) {
      return 'No activities recorded';
    }
    
    final sorted = metrics.activityTypeBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.map((entry) => 
      '• ${entry.key}: ${entry.value} activities'
    ).join('\n');
  }

  String _formatActivityBreakdownDetailed() {
    if (metrics.activityTypeBreakdown.isEmpty) {
      return 'No activities recorded';
    }
    
    final sorted = metrics.activityTypeBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.map((entry) {
      final percentage = (entry.value / metrics.totalActivities * 100).toStringAsFixed(1);
      return '${entry.key}: ${entry.value} activities (${percentage}%)';
    }).join('\n');
  }

  String _formatRecentActivities() {
    if (activityLogs.isEmpty) {
      return 'No activities recorded';
    }
    
    final recent = activityLogs.take(DashboardConstants.maxRecentActivities).toList();
    return recent.map((log) => 
      '${app_date_utils.DateUtils.formatDate(log.date)} - ${log.activityType}: ${log.duration}min, ${log.calories.toStringAsFixed(0)} cal'
    ).join('\n');
  }

  String _formatActivityLog() {
    if (activityLogs.isEmpty) {
      return 'No activities recorded';
    }
    
    final sorted = List<ActivityLogModel>.from(activityLogs)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return sorted.map((log) => 
      '${app_date_utils.DateUtils.formatDate(log.date)} ${app_date_utils.DateUtils.formatTime(log.date)} - ${log.activityType} - ${log.duration}min - ${log.calories.toStringAsFixed(0)} cal'
    ).join('\n');
  }

  String _generatePerformanceAnalysis() {
    if (activityLogs.isEmpty) {
      return 'Insufficient data for analysis';
    }
    
    final avgCalories = metrics.averageCaloriesPerActivity;
    final avgDuration = metrics.averageDuration;
    
    String analysis = 'Based on your activity data:\n\n';
    
    if (avgCalories > DashboardConstants.highIntensityCalories) {
      analysis += '🔥 High intensity activities detected!\n';
    } else if (avgCalories > DashboardConstants.moderateIntensityCalories) {
      analysis += '💪 Good moderate activity level\n';
    } else {
      analysis += '🚶‍♂️ Light activity level - consider increasing intensity\n';
    }
    
    if (avgDuration > DashboardConstants.excellentDuration) {
      analysis += '⏱️ Excellent workout duration\n';
    } else if (avgDuration > DashboardConstants.goodDuration) {
      analysis += '⏱️ Good workout duration\n';
    } else {
      analysis += '⏱️ Short workouts - consider longer sessions\n';
    }
    
    return analysis;
  }
} 