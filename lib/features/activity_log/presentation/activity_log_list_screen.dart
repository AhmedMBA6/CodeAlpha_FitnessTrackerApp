import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/activity_log_cubit.dart'; // Will be renamed to activity_log_list_cubit.dart in a later step
import '../data/models/activity_log_model.dart';
import 'widgets/activity_log_form_screen.dart';
import '../../activity_goals/data/repositories/activity_goal_repository.dart';
import '../../activity_goals/data/models/activity_goal.dart';
import '../../activity_log/data/repos/activity_log_goal_link_repository.dart';
import '../../activity_log/data/models/activity_log_goal_link.dart';
import '../logic/activity_log_form_cubit.dart';
import '../../activity_log/data/repos/activity_log_repository.dart';

/// Screen displaying the list of activity logs and related actions.
class ActivityLogListScreen extends StatelessWidget {
  const ActivityLogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ActivityLogScaffold();
  }
}

/// Scaffold with AppBar, FAB, and BlocListener for Activity Log
class _ActivityLogScaffold extends StatefulWidget {
  const _ActivityLogScaffold();
  @override
  State<_ActivityLogScaffold> createState() => _ActivityLogScaffoldState();
}

// Add enum for filter type at the top of the file (or inside the _ActivityLogScaffoldState class)
enum LogFilterType { all, goalLinked, unlinked }

class _ActivityLogScaffoldState extends State<_ActivityLogScaffold> {
  LogFilterType _filterType = LogFilterType.all;

  void _showForm(BuildContext parentContext, {ActivityLogModel? log}) async {
    if (log != null) {
      // Fetch linked goals for the log
      final linkRepo = SQLiteActivityLogGoalLinkRepository();
      final goalRepo = ActivityGoalRepository();
      final links = await linkRepo.getLinksForActivityLog(log.id.toString());
      final goalIds = links.map((l) => l.goalId).toSet();
      final allGoals = await goalRepo.getAllGoals();
      final linkedGoals = allGoals.where((g) => goalIds.contains(g.id)).toList();
      Navigator.of(parentContext).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (ctx) => BlocProvider(
            create: (_) => ActivityLogFormCubit(
              goalRepository: goalRepo,
              logRepository: ActivityLogRepository(linkRepo: linkRepo),
              linkRepository: linkRepo,
              initialLog: log,
              initialGoals: linkedGoals,
            ),
            child: ActivityLogFormScreen(
              initialLog: log,
              initialGoals: linkedGoals,
            ),
          ),
        ),
      );
    } else {
      final linkRepo = SQLiteActivityLogGoalLinkRepository();
      final goalRepo = ActivityGoalRepository();
      Navigator.of(parentContext).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (ctx) => BlocProvider(
            create: (_) => ActivityLogFormCubit(
              goalRepository: goalRepo,
              logRepository: ActivityLogRepository(linkRepo: linkRepo),
              linkRepository: linkRepo,
            ),
            child: const ActivityLogFormScreen(),
          ),
        ),
      );
    }
  }

  void _resetFilter() => setState(() => _filterType = LogFilterType.all);

  @override
  Widget build(BuildContext context) {
    return _ActivityLogListener(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity Log'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _filterType == LogFilterType.all,
                      onSelected: (_) => setState(() => _filterType = LogFilterType.all),
                      tooltip: 'Show all activity logs',
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Goal-linked'),
                      selected: _filterType == LogFilterType.goalLinked,
                      onSelected: (_) => setState(() => _filterType = LogFilterType.goalLinked),
                      tooltip: 'Show only logs linked to a goal',
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Unlinked'),
                      selected: _filterType == LogFilterType.unlinked,
                      onSelected: (_) => setState(() => _filterType = LogFilterType.unlinked),
                      tooltip: 'Show only logs not linked to a goal',
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _ActivityLogListBody(
                filterType: _filterType,
                showForm: (ctx, {log}) => _showForm(ctx, log: log),
                resetFilter: _resetFilter,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(context),
          tooltip: 'Add Activity',
          heroTag: 'add_activity_fab',
          child: const Icon(Icons.add, semanticLabel: 'Add Activity Button'),
        ),
      ),
    );
  }
}

/// BlocListener for ActivityLogCubit to handle goal completion dialogs
class _ActivityLogListener extends StatefulWidget {
  final Widget child;
  const _ActivityLogListener({required this.child});
  @override
  State<_ActivityLogListener> createState() => _ActivityLogListenerState();
}

class _ActivityLogListenerState extends State<_ActivityLogListener> {
  final List<int> _shownGoalLogIds = [];
  List<ActivityLogModel> _previousActivities = [];

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityLogListCubit, ActivityLogState>(
      listener: (context, state) async {
        if (state is ActivityLogSuccess) {
          final prevIds = _previousActivities.map((e) => e.id).toSet();
          final newLogs = state.activities.where((log) => !prevIds.contains(log.id)).toList();
          for (final log in newLogs) {
            // Removed legacy goal completion logic that referenced log.goalId and advanced goal logic.
          }
          _previousActivities = List.from(state.activities);
        }
      },
      child: widget.child,
    );
  }
}

/// List rendering and filtering for Activity Log
class _ActivityLogListBody extends StatelessWidget {
  final LogFilterType filterType;
  final void Function(BuildContext, {ActivityLogModel? log}) showForm;
  final void Function()? resetFilter;
  const _ActivityLogListBody({required this.filterType, required this.showForm, this.resetFilter});

  Future<List<ActivityGoal>> _fetchLinkedGoals(ActivityLogModel log) async {
    try {
      if (log.id == null) return [];
      
      final linkRepo = SQLiteActivityLogGoalLinkRepository();
      final goalRepo = ActivityGoalRepository();
      final links = await linkRepo.getLinksForActivityLog(log.id.toString());
      
      if (links.isEmpty) return [];
      
      final goalIds = links.map((l) => l.goalId).toSet();
      final allGoals = await goalRepo.getAllGoals();
      return allGoals.where((g) => goalIds.contains(g.id)).toList();
    } catch (e) {
      // Log error but don't crash the UI
      debugPrint('Error fetching linked goals for log ${log.id}: $e');
      return [];
    }
  }

  Future<bool> _isGoalLinked(ActivityLogModel log) async {
    try {
      if (log.id == null) return false;
      
      final linkRepo = SQLiteActivityLogGoalLinkRepository();
      final links = await linkRepo.getLinksForActivityLog(log.id.toString());
      return links.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if log ${log.id} is linked: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityLogListCubit, ActivityLogState>(
      builder: (context, state) {
        if (state is ActivityLogLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ActivityLogSuccess) {
          var activities = state.activities;
          // Fetch all links for all logs for filtering
          return FutureBuilder<List<ActivityLogGoalLink>>(
            future: SQLiteActivityLogGoalLinkRepository().getAllLinks(),
            builder: (context, linkSnap) {
              final allLinks = linkSnap.data ?? [];
              // Map logId to links for efficient filtering
              final Map<String, List<ActivityLogGoalLink>> logLinks = {};
              for (final link in allLinks) {
                logLinks.putIfAbsent(link.activityLogId, () => []).add(link);
              }
              
              // Apply filter based on linked goals
              if (filterType == LogFilterType.goalLinked) {
               activities = activities.where((log) {
                 if (log.id == null) return false;
                 final links = logLinks[log.id.toString()];
                 return links != null && links.isNotEmpty;
               }).toList();
              } else if (filterType == LogFilterType.unlinked) {
               activities = activities.where((log) {
                 if (log.id == null) return true; // Consider logs without ID as unlinked
                 final links = logLinks[log.id.toString()];
                 return links == null || links.isEmpty;
               }).toList();
              }
              
              if (activities.isEmpty) {
                String message;
                IconData icon;
                Widget? action;
                if (filterType == LogFilterType.goalLinked) {
                 message = 'No goal-linked activities found.\n\nActivities linked to goals will appear here. Try linking an activity to a goal in the activity form!';
                  icon = Icons.flag;
                  action = OutlinedButton(
                    onPressed: resetFilter,
                    child: const Text('Show All'),
                  );
                } else if (filterType == LogFilterType.unlinked) {
                 message = 'No unlinked activities found.\n\nAll your activities are linked to goals! Great job staying organized!';
                  icon = Icons.link_off;
                  action = OutlinedButton(
                    onPressed: resetFilter,
                    child: const Text('Show All'),
                  );
                } else {
                  message = 'No activities yet!\nStart tracking your fitness journey.';
                  icon = Icons.inbox;
                  action = ElevatedButton(
                    onPressed: () => showForm(context),
                    child: const Text('Add Activity'),
                  );
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      action,
                    ],
                  ),
                );
              }
              return ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final log = activities[i];
                  return FutureBuilder<List<ActivityGoal>>(
                    future: _fetchLinkedGoals(log),
                    builder: (context, snapshot) {
                      final linkedGoals = snapshot.data ?? [];
                      return _EnhancedActivityCard(
                        log: log,
                        linkedGoals: linkedGoals,
                        onEdit: () async {
                          try {
                            // Show loading indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 16),
                                    Text('Loading activity details...'),
                                  ],
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            
                            // Navigate to edit form
                            showForm(context, log: log);
                            
                            // Show success message when returning from edit
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Activity "${log.activityType}" updated successfully'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            // Show error message
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to edit activity: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        onDelete: () async {
                          // Show confirmation dialog
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Row(
                                children: const [
                                  Icon(Icons.warning, color: Colors.red, size: 24),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Delete Activity',
                                      style: TextStyle(fontSize: 18),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              content: const Text('Are you sure you want to delete this activity log? This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.delete),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  label: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                           try {
                             // Validate activity ID before proceeding
                             if (log.id == null || log.id!.isEmpty) {
                               throw Exception('Activity ID is null or empty');
                             }
                             
                             // Show loading indicator
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                 content: Row(
                                   children: [
                                     SizedBox(
                                       width: 20,
                                       height: 20,
                                       child: CircularProgressIndicator(strokeWidth: 2),
                                     ),
                                     SizedBox(width: 16),
                                     Text('Deleting activity...'),
                                   ],
                                 ),
                                 duration: Duration(seconds: 2),
                               ),
                             );
                             
                             // Delete the activity
                               await context.read<ActivityLogListCubit>().deleteActivity(log.id!);
                               
                               // Show success message
                               if (context.mounted) {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                     content: Text('Activity "${log.activityType}" deleted successfully'),
                                     backgroundColor: Colors.green,
                                     action: SnackBarAction(
                                       label: 'Undo',
                                       textColor: Colors.white,
                                       onPressed: () {
                                         // TODO: Implement undo functionality
                                         ScaffoldMessenger.of(context).showSnackBar(
                                           const SnackBar(content: Text('Undo functionality coming soon')),
                                         );
                                       },
                                     ),
                                   ),
                                 );
                               }
                           } catch (e) {
                             // Show error message
                             if (context.mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   content: Text('Failed to delete activity: ${e.toString()}'),
                                   backgroundColor: Colors.red,
                                   duration: const Duration(seconds: 4),
                                 ),
                               );
                             }
                           }
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        } else if (state is ActivityLogError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Couldn’t load activity logs', style: TextStyle(color: Colors.red, fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: resetFilter,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Enhanced activity card with modern design and better goal detection
class _EnhancedActivityCard extends StatelessWidget {
  final ActivityLogModel log;
  final List<ActivityGoal> linkedGoals;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EnhancedActivityCard({
    required this.log,
    required this.linkedGoals,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'run':
      case 'running':
        return Icons.directions_run;
      case 'walk':
      case 'walking':
        return Icons.directions_walk;
      case 'cycle':
      case 'cycling':
        return Icons.directions_bike;
      case 'swim':
      case 'swimming':
        return Icons.pool;
      case 'gym':
      case 'workout':
        return Icons.fitness_center;
      default:
        return Icons.sports;
    }
  }

  Color _getActivityColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'run':
      case 'running':
        return Colors.red;
      case 'walk':
      case 'walking':
        return Colors.green;
      case 'cycle':
      case 'cycling':
        return Colors.blue;
      case 'swim':
      case 'swimming':
        return Colors.cyan;
      case 'gym':
      case 'workout':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final activityDate = DateTime(date.year, date.month, date.day);

    if (activityDate == today) {
      return 'Today';
    } else if (activityDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activityColor = _getActivityColor(log.activityType);
    final activityIcon = _getActivityIcon(log.activityType);
    final hasLinkedGoals = linkedGoals.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with activity type and actions
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: activityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(activityIcon, color: activityColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.activityType.toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: activityColor,
                          ),
                        ),
                        Text(
                          _formatDate(log.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Goal indicator
                  if (hasLinkedGoals)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flag, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${linkedGoals.length} Goal${linkedGoals.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Stats row
              Row(
                children: [
                  _StatItem(
                    icon: Icons.timer,
                    label: 'Duration',
                    value: '${log.duration} min',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _StatItem(
                    icon: Icons.local_fire_department,
                    label: 'Calories',
                    value: '${log.calories}',
                    color: Colors.orange,
                  ),
                  if (log.distance != null) ...[
                    const SizedBox(width: 16),
                    _StatItem(
                      icon: Icons.straighten,
                      label: 'Distance',
                      value: '${log.distance != null ? log.distance!.toStringAsFixed(2) : '-'} km',
                      color: Colors.green,
                    ),
                  ],
                ],
              ),
              
              // Heart rate if available
              if (log.heartRate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Heart Rate: ${log.heartRate} bpm',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Linked goals section
              if (hasLinkedGoals) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Linked Goals:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: linkedGoals.map((goal) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag, color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          goal.description ?? 'Goal',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
              
              // Action buttons
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                 Expanded(
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.end,
                     children: [
                       OutlinedButton.icon(
                         onPressed: onEdit,
                         icon: const Icon(Icons.edit, size: 16),
                         label: const Text('Edit'),
                         style: OutlinedButton.styleFrom(
                           foregroundColor: theme.colorScheme.primary,
                           side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                         ),
                       ),
                       const SizedBox(width: 8),
                       OutlinedButton.icon(
                         onPressed: onDelete,
                         icon: const Icon(Icons.delete, size: 16),
                         label: const Text('Delete'),
                         style: OutlinedButton.styleFrom(
                           foregroundColor: Colors.red,
                           side: BorderSide(color: Colors.red.withOpacity(0.5)),
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                         ),
                       ),
                     ],
                   ),
                 ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual stat item widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 