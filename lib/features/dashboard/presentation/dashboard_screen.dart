import 'package:codealpha_fitness_tracker_app/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/dashboard_summary_row.dart';
import 'widgets/weekly_chart.dart';
import 'widgets/weekly_duration_line_chart.dart';
import 'widgets/weekly_activity_pie_chart.dart';
import 'widgets/date_range_filter.dart';
import 'widgets/dashboard_export.dart';
import '../../dashboard/logic/dashboard_cubit.dart';
import '../../../core/constants/dashboard_constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedType = DashboardConstants.defaultActivityType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DashboardCubit>().refreshDashboard(),
            tooltip: 'Refresh dashboard',
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DashboardCubit>().refreshDashboard(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is DashboardLoaded) {
            final today = state.todaySummary;
            final weekly = state.weeklySummaries;
            final selectedType = state.activityTypeFilter;
            final metrics = state.metrics;
            
            return RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().refreshDashboard(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date Range Filter
                    DateRangeFilter(
                      startDate: state.startDate,
                      endDate: state.endDate,
                      onDateRangeChanged: (start, end) {
                        context.read<DashboardCubit>().updateDateRange(start, end);
                      },
                      onReset: () {
                        context.read<DashboardCubit>().resetFilters();
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Activity Type Filter
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Text('Activity Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 16),
                            DropdownButton<String>(
                              value: selectedType,
                              items: DashboardConstants.activityTypes.map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              )).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  context.read<DashboardCubit>().updateActivityTypeFilter(val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Enhanced Summary Cards
                    DashboardSummaryRow(today: today, metrics: metrics),
                    const SizedBox(height: 32),
                    
                    // Export & Share
                    DashboardExport(
                      metrics: metrics,
                      activityLogs: state.activityLogs,
                      startDate: state.startDate,
                      endDate: state.endDate,
                    ),
                    const SizedBox(height: 32),
                    
                    // Charts Section
                    const Text('Weekly Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    WeeklyChart(weeklySummaries: weekly),
                    const SizedBox(height: 32),
                    
                    const Text('Weekly Duration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    WeeklyDurationLineChart(weeklySummaries: weekly),
                    const SizedBox(height: 32),
                    
                    const Text('Activity Type Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    WeeklyActivityPieChart(activityLogs: state.activityLogs),
                    const SizedBox(height: 32),
                    
                    // Quick Actions
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // Navigate to add activity
                                      Navigator.pushNamed(context, Routes.activityLogList);
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Activity'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // Navigate to activity history
                                      Navigator.pushNamed(context, '/activity-log');
                                    },
                                    icon: const Icon(Icons.history),
                                    label: const Text('View History'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
} 