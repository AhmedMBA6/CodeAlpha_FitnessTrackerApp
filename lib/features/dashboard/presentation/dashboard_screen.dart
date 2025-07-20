import 'package:flutter/material.dart';

import '../../activity_log/data/models/activity_log_model.dart';
import '../data/dashboard_aggregator.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../activity_goals/data/models/activity_goal.dart';
import '../../activity_log/data/repos/activity_log_repository.dart';

import '../../activity_log/data/repos/activity_log_goal_link_repository.dart';
import '../../activity_goals/data/repositories/activity_goal_repository.dart';

/// Main screen displaying the dashboard with analytics, goals, filters, and charts.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

/// State for [DashboardScreen]. Handles UI logic and dashboard interactions.
class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  Map<String, dynamic>? _dashboardStats;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _loading = true);
    final logRepo = ActivityLogRepository(linkRepo: SQLiteActivityLogGoalLinkRepository());
    final goalRepo = ActivityGoalRepository();
    final linkRepo = SQLiteActivityLogGoalLinkRepository();
    final logs = await logRepo.getAllActivities();
    final goals = await goalRepo.getAllGoals();
    final links = await linkRepo.getAllLinks();
    final stats = DashboardAggregator.aggregateWithJoinModel(logs: logs, goals: goals, links: links);
    if (mounted) {
      setState(() {
        _dashboardStats = stats;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _dashboardStats == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final stats = _dashboardStats!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, semanticLabel: 'Refresh Dashboard'),
            onPressed: _fetchDashboardData,
            tooltip: 'Refresh dashboard',
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: DashboardSectionCard(child: ListTile(
              leading: Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
              title: const Text('Goal Analytics'),
              subtitle: const Text('View your goal and activity statistics'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () { Navigator.pushNamed(context, '/goal-analytics'); },
            ))),
            SliverToBoxAdapter(child: DashboardSectionCard(child: ListTile(
              leading: Icon(Icons.flag, color: Theme.of(context).colorScheme.primary),
              title: const Text('My Goals'),
              subtitle: const Text('View and manage your activity goals'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () { Navigator.pushNamed(context, '/goals'); },
            ))),
            SliverToBoxAdapter(child: _ActiveGoalsCard(stats: stats)),
            SliverToBoxAdapter(child: _TopGoalsList(goals: List<Map<String, dynamic>>.from(stats['topGoals'] ?? []))),
            SliverToBoxAdapter(child: DashboardSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top Goals by Linked Logs', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if ((stats['topLinkedGoals'] as List).isEmpty)
                    const Text('No goals with linked logs.'),
                  if ((stats['topLinkedGoals'] as List).isNotEmpty)
                    SizedBox(
                      height: 220,
                      child: _TopLinkedGoalsBarChart(
                        topLinkedGoals: List<Map<String, dynamic>>.from(stats['topLinkedGoals']).take(5).toList(),
                        onBarTap: (goal, logs) => _showLinkedLogsDialog(context, goal, logs),
                      ),
                    ),
                ],
              ),
            )),
            SliverToBoxAdapter(child: DashboardSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Log Distribution by Goal', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if ((stats['goalLinkedLogCount'] as Map).isEmpty)
                    const Text('No logs linked to goals.'),
                  if ((stats['goalLinkedLogCount'] as Map).isNotEmpty)
                    SizedBox(
                      height: 220,
                      child: _GoalLogDistributionPieChart(
                        goalLinkedLogCount: Map<String, int>.from(stats['goalLinkedLogCount']),
                        goals: List<ActivityGoal>.from(stats['topGoals'].map((g) => g['goal'])),
                        onSliceTap: (goal, logs) => _showLinkedLogsDialog(context, goal, logs),
                        goalToLogs: Map<String, List<ActivityLogModel>>.from(stats['goalToLogs']),
                      ),
                    ),
                ],
              ),
            )),
            SliverToBoxAdapter(child: DashboardSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Activity Logs Linked to Goals', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if ((stats['logsLinkedToGoals'] as List).isEmpty)
                    const Text('No logs linked to goals.'),
                  ...List<ActivityLogModel>.from(stats['logsLinkedToGoals'] ?? []).map((log) => ListTile(
                    title: Text(log.activityType),
                    subtitle: Text('Date: ${log.date.toLocal().toIso8601String().split('T').first}'),
                  )),
                  const SizedBox(height: 16),
                  const Text('Unlinked Activity Logs', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if ((stats['logsUnlinked'] as List).isEmpty)
                    const Text('All logs are linked to goals.'),
                  ...List<ActivityLogModel>.from(stats['logsUnlinked'] ?? []).map((log) => ListTile(
                    title: Text(log.activityType),
                    subtitle: Text('Date: ${log.date.toLocal().toIso8601String().split('T').first}'),
                  )),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class DashboardSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const DashboardSectionCard({required this.child, this.padding, super.key});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class TitledListSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const TitledListSection({required this.title, required this.children, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ...children,
      ],
    );
  }
}

class _TrendsInsightsCard extends StatelessWidget {
  final List<ActivityLogModel> activityLogs;
  const _TrendsInsightsCard({required this.activityLogs});
  @override
  Widget build(BuildContext context) {
    final trends = DashboardAggregator.getWeeklyTrends(activityLogs);
    final bests = DashboardAggregator.getPersonalBests(activityLogs);
    final streak = DashboardAggregator.getCurrentStreak(activityLogs);
    final bestDistance = bests['distance'];
    final bestCalories = bests['calories'];
    final bestDuration = bests['duration'];
    return Card(
      color: Colors.amber[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Trends & Insights', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _TrendStat(label: 'Calories', value: trends['calories']),
                _TrendStat(label: 'Duration', value: trends['duration']),
                _TrendStat(label: 'Activities', value: trends['activities']),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('Personal Bests', style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (bestDistance != null)
                  _BestStat(label: 'Distance', value: '${(bestDistance.distance ?? 0).toStringAsFixed(2)} km', date: bestDistance.date),
                if (bestCalories != null)
                  _BestStat(label: 'Calories', value: '${(bestCalories.calories ?? 0).toStringAsFixed(0)}', date: bestCalories.date),
                if (bestDuration != null)
                  _BestStat(label: 'Duration', value: '${(bestDuration.duration ?? 0)} min', date: bestDuration.date),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.red),
                const SizedBox(width: 8),
                Text('Current Streak: ', style: Theme.of(context).textTheme.titleSmall),
                Text('$streak days', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendStat extends StatelessWidget {
  final String label;
  final double? value;
  const _TrendStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final color = (value ?? 0) > 0 ? Colors.green : ((value ?? 0) < 0 ? Colors.red : Colors.grey);
    final sign = (value ?? 0) > 0 ? '+' : '';
    return Expanded(
      child: Column(
        children: [
          Text('$sign${(value ?? 0).toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _BestStat extends StatelessWidget {
  final String label;
  final String value;
  final DateTime? date;
  const _BestStat({required this.label, required this.value, required this.date});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 12)),
          if (date != null)
            Text('${date!.month}/${date!.day}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ActiveGoalsCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _ActiveGoalsCard({required this.stats});
  @override
  Widget build(BuildContext context) {
    final total = stats['totalGoals'] ?? 0;
    final completed = stats['completedGoals'] ?? 0;
    final pending = stats['pendingGoals'] ?? 0;
    final completionRate = stats['completionRate'] != null ? (stats['completionRate'] * 100).toStringAsFixed(1) : '-';
    final avgProgress = stats['averageProgress'] != null ? (stats['averageProgress'] * 100).toStringAsFixed(1) : '-';
    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.green),
                const SizedBox(width: 8),
                Text('Active Goals', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _GoalStat(label: 'Total', value: total.toString()),
                _GoalStat(label: 'Completed', value: completed.toString()),
                _GoalStat(label: 'In Progress', value: pending.toString()),
                _GoalStat(label: 'Avg Progress', value: '$avgProgress%'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _GoalStat(label: 'Completion Rate', value: '$completionRate%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalStat extends StatelessWidget {
  final String label;
  final String value;
  const _GoalStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _TopGoalsList extends StatefulWidget {
  final List<Map<String, dynamic>> goals;
  const _TopGoalsList({required this.goals});
  @override
  State<_TopGoalsList> createState() => _TopGoalsListState();
}

class _TopGoalsListState extends State<_TopGoalsList> {
  String _goalTypeFilter = 'all';
  String _sortBy = 'progress_desc';

  List<Map<String, dynamic>> get _filteredSortedGoals {
    var filtered = widget.goals;
    // Filter by goal type
    if (_goalTypeFilter != 'all') {
      filtered = filtered.where((g) {
        final goal = g['goal'] as ActivityGoal;
        return (_goalTypeFilter == 'distance' && (goal.unit == 'km' || goal.unit == 'miles'));
      }).toList();
    }
    // Sort
    filtered.sort((a, b) {
      final ga = a['goal'] as ActivityGoal;
      final gb = b['goal'] as ActivityGoal;
      final pa = (a['goalProgress'] ?? 0.0) as double;
      final pb = (b['goalProgress'] ?? 0.0) as double;
      switch (_sortBy) {
        case 'progress_desc':
          return pb.compareTo(pa);
        case 'progress_asc':
          return pa.compareTo(pb);
        case 'date_newest':
          return gb.createdAt.compareTo(ga.createdAt);
        case 'date_oldest':
          return ga.createdAt.compareTo(gb.createdAt);
        case 'name_az':
          return (ga.description ?? '').compareTo(gb.description ?? '');
        case 'name_za':
          return (gb.description ?? '').compareTo(ga.description ?? '');
        default:
          return 0;
      }
    });
    return filtered;
  }

  void _markGoalAsComplete(Map<String, dynamic> g, ActivityGoal goal) async {
    // Legacy route-tracking logic removed: getRouteById, updateRoute, etc.
    // If you want to mark a goal as complete, implement the logic using ActivityGoalRepository or similar.
    // Goal is non-nullable, no need to check
    // Show a snackbar for demonstration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Goal marked as complete!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            // Undo logic placeholder
            if (mounted) {
              setState(() {}); // Refresh UI
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Undo: Goal completion reverted.')),
              );
            }
          },
        ),
      ),
    );
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Top Goals In Progress',
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          value: _goalTypeFilter,
                          isDense: true,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All', maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'distance', child: Text('Distance', maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'destination', child: Text('Destination', maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (v) => setState(() => _goalTypeFilter = v!),
                          underline: SizedBox.shrink(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          icon: const Icon(Icons.filter_list),
                          hint: const Text('Type'),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _sortBy,
                          isDense: true,
                          items: const [
                            DropdownMenuItem(value: 'progress_desc', child: Text('Progress ↓', maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'progress_asc', child: Text('Progress ↑', maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'date_newest', child: Text('Newest', maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'date_oldest', child: Text('Oldest', maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'name_az', child: Text('A-Z', maxLines: 1, overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'name_za', child: Text('Z-A', maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (v) => setState(() => _sortBy = v!),
                          underline: SizedBox.shrink(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          icon: const Icon(Icons.sort),
                          hint: const Text('Sort'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._filteredSortedGoals.map((g) {
              final goal = g['goal'] as ActivityGoal;
              final progress = (g['goalProgress'] ?? 0.0) as double;
              final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);
              final desc = goal.description ?? 'Goal';
              final typeLabel = (goal.unit == 'km' || goal.unit == 'miles') ? 'Distance' : 'Other';
              final created = goal.createdAt;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                desc,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(label: Text(typeLabel, maxLines: 1, overflow: TextOverflow.ellipsis)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.info_outline, color: Colors.blue),
                              tooltip: 'View Details',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(desc),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Type: $typeLabel'),
                                        Text('Created: ${created.month}/${created.day}/${created.year}'),
                                        Text('Progress: $percent%'),
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation<Color>(progress >= 1.0 ? Colors.green : Colors.orange),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text('Close'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // GoalInputDialog removed. If needed, implement a new dialog for editing goals.
                                        },
                                        child: const Text('Edit'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // deleteGoalFromRoute removed. Implement if needed.
                                        },
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                      if (progress < 1.0)
                                        TextButton(
                                          onPressed: () => _markGoalAsComplete(g, goal),
                                          child: const Text('Mark as Complete'),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(progress >= 1.0 ? Colors.green : Colors.orange),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('$percent%', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ComparisonChart extends StatelessWidget {
  final List<ActivityLogModel> logs;
  const _ComparisonChart({required this.logs});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final thisWeek = List.generate(7, (i) => thisWeekStart.add(Duration(days: i)));
    final lastWeek = List.generate(7, (i) => lastWeekStart.add(Duration(days: i)));
    double sumForDay(DateTime day, List<ActivityLogModel> logs, String metric) {
      final start = DateTime(day.year, day.month, day.day);
      final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
      return logs.where((l) => l.date.isAfter(start.subtract(const Duration(seconds: 1))) && l.date.isBefore(end.add(const Duration(seconds: 1))))
        .fold(0.0, (sum, l) {
          if (metric == 'calories') return sum + l.calories;
          if (metric == 'duration') return sum + l.duration;
          if (metric == 'distance') return sum + (l.distance ?? 0.0);
          return sum;
        });
    }
    final metrics = [
      {'label': 'Calories', 'color': Colors.purple, 'metric': 'calories'},
      {'label': 'Duration (min)', 'color': Colors.blue, 'metric': 'duration'},
      {'label': 'Distance (km)', 'color': Colors.green, 'metric': 'distance'},
    ];
    return Card(
      color: Colors.purple[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.purple),
                const SizedBox(width: 8),
                Text('This Week vs Last Week', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            ...metrics.map((m) {
              final thisWeekData = thisWeek.map((d) => sumForDay(d, logs, m['metric'] as String)).toList();
              final lastWeekData = lastWeek.map((d) => sumForDay(d, logs, m['metric'] as String)).toList();
              final maxY = ([...thisWeekData, ...lastWeekData].fold<double>(0, (prev, el) => el > prev ? el : prev) * 1.2).clamp(10, double.infinity) as double;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m['label'] as String, style: TextStyle(color: m['color'] as Color, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 120,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxY,
                        barGroups: List.generate(7, (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: lastWeekData[i],
                              color: Colors.grey,
                              width: 10,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            BarChartRodData(
                              toY: thisWeekData[i],
                              color: m['color'] as Color,
                              width: 10,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        )),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index > 6) return const SizedBox.shrink();
                                return Text(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][index], style: const TextStyle(fontSize: 12));
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: true),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TopLinkedGoalsBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> topLinkedGoals;
  final void Function(ActivityGoal goal, List<ActivityLogModel> logs)? onBarTap;
  const _TopLinkedGoalsBarChart({required this.topLinkedGoals, this.onBarTap});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (topLinkedGoals.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Semantics(
        label: 'Bar chart of top goals by number of linked logs',
        child: Card(
          color: colorScheme.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (topLinkedGoals.first['linkedCount'] as int).toDouble() + 1,
                barGroups: List.generate(topLinkedGoals.length, (i) {
                  final g = topLinkedGoals[i];
                  final count = g['linkedCount'] as int;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: colorScheme.primary,
                        width: 24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                    barsSpace: 4,
                  );
                }),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    if (event.isInterestedForInteractions && response != null && response.spot != null && onBarTap != null) {
                      final index = response.spot!.touchedBarGroupIndex;
                      if (index >= 0 && index < topLinkedGoals.length) {
                        final g = topLinkedGoals[index];
                        final goal = g['goal'] as ActivityGoal;
                        final logs = List<ActivityLogModel>.from(g['linkedLogs'] ?? []);
                        onBarTap!(goal, logs);
                      }
                    }
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final g = topLinkedGoals[group.x.toInt()];
                      final goal = g['goal'] as ActivityGoal;
                      final count = g['linkedCount'] as int;
                      return BarTooltipItem(
                        '${goal.description ?? 'Goal'}\nLogs: $count',
                        TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= topLinkedGoals.length) return const SizedBox.shrink();
                        final g = topLinkedGoals[index];
                        final goal = g['goal'] as ActivityGoal;
                        return Tooltip(
                          message: 'Goal: ${goal.description ?? 'Goal'}',
                          child: Semantics(
                            label: 'Goal: ${goal.description ?? 'Goal'}',
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                goal.description ?? 'Goal',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalLogDistributionPieChart extends StatelessWidget {
  final Map<String, int> goalLinkedLogCount;
  final List<ActivityGoal> goals;
  final void Function(ActivityGoal goal, List<ActivityLogModel> logs)? onSliceTap;
  final Map<String, List<ActivityLogModel>> goalToLogs;
  const _GoalLogDistributionPieChart({required this.goalLinkedLogCount, required this.goals, this.onSliceTap, required this.goalToLogs});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (goalLinkedLogCount.isEmpty) return const SizedBox.shrink();
    final sorted = goalLinkedLogCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    final otherCount = sorted.length > 5 ? sorted.skip(5).fold<int>(0, (sum, e) => sum + e.value) : 0;
    final pieSections = <PieChartSectionData>[];
    for (var i = 0; i < top.length; i++) {
      final entry = top[i];
      final goal = goals.firstWhere((g) => g.id == entry.key, orElse: () => ActivityGoal(id: entry.key, goalType: GoalType.quantitative, createdAt: DateTime.now(), isArchived: false));
      pieSections.add(PieChartSectionData(
        value: entry.value.toDouble(),
        color: colorScheme.primaryContainer,
        title: goal.description ?? 'Goal',
        radius: 60,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
        badgeWidget: Tooltip(
          message: 'Goal: ${goal.description ?? 'Goal'}, Logs: ${entry.value}',
          child: Semantics(
            label: 'Goal: ${goal.description ?? 'Goal'}, Logs: ${entry.value}',
            child: const SizedBox(width: 1, height: 1),
          ),
        ),
        badgePositionPercentageOffset: .98,
      ));
    }
    if (otherCount > 0) {
      pieSections.add(PieChartSectionData(
        value: otherCount.toDouble(),
        color: colorScheme.secondary,
        title: 'Other',
        radius: 60,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSecondary),
        badgeWidget: Tooltip(
          message: 'Other goals',
          child: Semantics(label: 'Other goals', child: const SizedBox(width: 1, height: 1)),
        ),
      ));
    }
    return Semantics(
      label: 'Pie chart of log distribution by goal',
      child: Card(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sections: pieSections,
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (event.isInterestedForInteractions && response != null && response.touchedSection != null && onSliceTap != null) {
                    final index = response.touchedSection!.touchedSectionIndex;
                    if (index >= 0 && index < top.length) {
                      final entry = top[index];
                      final goal = goals.firstWhere((g) => g.id == entry.key, orElse: () => ActivityGoal(id: entry.key, goalType: GoalType.quantitative, createdAt: DateTime.now(), isArchived: false));
                      final logs = goalToLogs[goal.id] ?? [];
                      onSliceTap!(goal, logs);
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showLinkedLogsDialog(BuildContext context, ActivityGoal goal, List<ActivityLogModel> logs) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Semantics(
        label: 'Logs for goal: ${goal.description ?? goal.id}',
        child: Text('Logs for: ${goal.description ?? goal.id}'),
      ),
      content: SizedBox(
        width: 350,
        child: logs.isEmpty
            ? const Text('No logs linked to this goal.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: logs.length,
                itemBuilder: (context, i) {
                  final log = logs[i];
                  return ListTile(
                    title: Semantics(label: 'Activity type: ${log.activityType}', child: Text(log.activityType)),
                    subtitle: Semantics(label: 'Date: ${log.date.toLocal().toIso8601String().split('T').first}', child: Text('Date: ${log.date.toLocal().toIso8601String().split('T').first}')),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
} 