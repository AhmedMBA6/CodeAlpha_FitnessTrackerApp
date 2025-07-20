import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../activity_log/data/models/activity_log_model.dart';
import '../../data/dashboard_aggregator.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../core/constants/dashboard_constants.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

/// Widget for exporting and sharing dashboard metrics and activity logs.
class DashboardExport extends StatefulWidget {
  final DashboardMetrics metrics;
  final List<ActivityLogModel> activityLogs;
  final DateTime? startDate;
  final DateTime? endDate;

  /// Creates a [DashboardExport] widget.
  const DashboardExport({
    super.key,
    required this.metrics,
    required this.activityLogs,
    this.startDate,
    this.endDate,
  });

  @override
  State<DashboardExport> createState() => _DashboardExportState();
}

class _DashboardExportState extends State<DashboardExport> {
  DateTime? _exportStart;
  DateTime? _exportEnd;
  String _selectedType = 'All';
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _exportStart = widget.startDate;
    _exportEnd = widget.endDate;
  }

  void _showExportOptions() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date Range'),
              subtitle: Text('${_exportStart != null ? app_date_utils.DateUtils.formatDate(_exportStart!) : 'Start'} - ${_exportEnd != null ? app_date_utils.DateUtils.formatDate(_exportEnd!) : 'End'}'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: _exportStart != null && _exportEnd != null ? DateTimeRange(start: _exportStart!, end: _exportEnd!) : null,
                  );
                  if (picked != null) {
                    setState(() {
                      _exportStart = picked.start;
                      _exportEnd = picked.end;
                    });
                  }
                },
              ),
            ),
            DropdownButton<String>(
              value: _selectedType,
              items: ['All', ...DashboardConstants.activityTypes].map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              )).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _exportAsCSV(context);
            },
            child: const Text('Export as CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _shareAsImage(context);
            },
            child: const Text('Share as Image'),
          ),
        ],
      ),
    );
  }

  void _exportAsCSV(BuildContext context) async {
    final logs = _filteredLogs();
    final csv = _generateCSV(logs);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/fitness_export.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Fitness Tracker Export');
  }

  void _shareAsImage(BuildContext context) async {
    final boundary = context.findRenderObject();
    final image = await _screenshotController.captureFromWidget(
      Material(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Fitness Dashboard', style: Theme.of(context).textTheme.headlineSmall),
              // You can add more widgets here for the screenshot
            ],
          ),
        ),
      ),
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/dashboard.png');
    await file.writeAsBytes(image);
    await Share.shareXFiles([XFile(file.path)], text: 'My Fitness Dashboard');
  }

  List<ActivityLogModel> _filteredLogs() {
    return widget.activityLogs.where((log) {
      final inDate = (_exportStart == null || !log.date.isBefore(_exportStart!)) && (_exportEnd == null || !log.date.isAfter(_exportEnd!));
      final typeMatch = _selectedType == 'All' || log.activityType == _selectedType;
      return inDate && typeMatch;
    }).toList();
  }

  String _generateCSV(List<ActivityLogModel> logs) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Time,Activity Type,Duration (min),Calories');
    for (final log in logs) {
      buffer.writeln('${app_date_utils.DateUtils.formatDate(log.date)},${app_date_utils.DateUtils.formatTime(log.date)},${log.activityType},${log.duration},${log.calories.toStringAsFixed(0)}');
    }
    return buffer.toString();
  }

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
                    icon: const Icon(Icons.text_snippet, semanticLabel: 'Export as Text'),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Export as Text', semanticsLabel: 'Export as Text Button', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareSummary(context),
                    icon: const Icon(Icons.share, semanticLabel: 'Share Summary'),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Share Summary', semanticsLabel: 'Share Summary Button', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
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
                    icon: const Icon(Icons.copy, semanticLabel: 'Copy to Clipboard'),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Copy to Clipboard', semanticsLabel: 'Copy to Clipboard Button', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDetailedReport(context),
                    icon: const Icon(Icons.assessment, semanticLabel: 'Detailed Report'),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Detailed Report', semanticsLabel: 'Detailed Report Button', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showExportOptions,
                    icon: const Icon(Icons.settings, semanticLabel: 'Custom Export Options'),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Custom Export', semanticsLabel: 'Custom Export Button', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
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
      builder: (context) => SafeArea(
        child: AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: SelectableText(content),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', semanticsLabel: 'Close Button'),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
              child: const Text('Copy', semanticsLabel: 'Copy Button'),
            ),
          ],
        ),
      ),
    );
  }

  String _generateSummary() {
    final dateRange = _formatDateRange();
    return '''
🏃‍♂️ Fitness Summary $dateRange

📊 Key Metrics:
• Total Activities: ${widget.metrics.totalActivities}
• Total Calories: ${widget.metrics.totalCalories.toStringAsFixed(0)}
• Total Duration: ${widget.metrics.totalDuration} minutes
• Average Duration: ${widget.metrics.averageDuration.toStringAsFixed(0)} minutes
• Average Calories per Activity: ${widget.metrics.averageCaloriesPerActivity.toStringAsFixed(0)}

�� Activity Breakdown:
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
Total Activities: ${widget.metrics.totalActivities}
Total Calories Burned: ${widget.metrics.totalCalories.toStringAsFixed(0)}
Total Duration: ${widget.metrics.totalDuration} minutes
Average Duration per Activity: ${widget.metrics.averageDuration.toStringAsFixed(0)} minutes
Average Calories per Activity: ${widget.metrics.averageCaloriesPerActivity.toStringAsFixed(0)}

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
Total Activities: ${widget.metrics.totalActivities}
Total Calories: ${widget.metrics.totalCalories.toStringAsFixed(0)}
Total Duration: ${widget.metrics.totalDuration} minutes
Average Duration: ${widget.metrics.averageDuration.toStringAsFixed(0)} minutes
Average Calories per Activity: ${widget.metrics.averageCaloriesPerActivity.toStringAsFixed(0)}

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
    return app_date_utils.DateUtils.formatDateRange(widget.startDate, widget.endDate);
  }

  String _formatActivityBreakdown() {
    if (widget.metrics.activityTypeBreakdown.isEmpty) {
      return 'No activities recorded';
    }
    
    final sorted = widget.metrics.activityTypeBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.map((entry) => 
      '• ${entry.key}: ${entry.value} activities'
    ).join('\n');
  }

  String _formatActivityBreakdownDetailed() {
    if (widget.metrics.activityTypeBreakdown.isEmpty) {
      return 'No activities recorded';
    }
    
    final sorted = widget.metrics.activityTypeBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.map((entry) {
      final percentage = (entry.value / widget.metrics.totalActivities * 100).toStringAsFixed(1);
      return '${entry.key}: ${entry.value} activities ($percentage%)';
    }).join('\n');
  }

  String _formatRecentActivities() {
    if (widget.activityLogs.isEmpty) {
      return 'No activities recorded';
    }
    
    final recent = widget.activityLogs.take(DashboardConstants.maxRecentActivities).toList();
    return recent.map((log) => 
      '${app_date_utils.DateUtils.formatDate(log.date)} - ${log.activityType}: ${log.duration}min, ${log.calories.toStringAsFixed(0)} cal'
    ).join('\n');
  }

  String _formatActivityLog() {
    if (widget.activityLogs.isEmpty) {
      return 'No activities recorded';
    }
    
    final sorted = List<ActivityLogModel>.from(widget.activityLogs)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return sorted.map((log) => 
      '${app_date_utils.DateUtils.formatDate(log.date)} ${app_date_utils.DateUtils.formatTime(log.date)} - ${log.activityType} - ${log.duration}min - ${log.calories.toStringAsFixed(0)} cal'
    ).join('\n');
  }

  String _generatePerformanceAnalysis() {
    if (widget.activityLogs.isEmpty) {
      return 'Insufficient data for analysis';
    }
    
    final avgCalories = widget.metrics.averageCaloriesPerActivity;
    final avgDuration = widget.metrics.averageDuration;
    
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