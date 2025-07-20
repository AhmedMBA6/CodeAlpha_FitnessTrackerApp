
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/activity_log_model.dart';
import '../data/repos/activity_log_repository.dart';
import '../data/repos/activity_log_goal_link_repository.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/di.dart';
import '../data/models/activity_log_goal_link.dart';

part 'activity_log_state.dart';

/// Cubit for managing activity log list state and actions.
class ActivityLogListCubit extends Cubit<ActivityLogState> {
  final ActivityLogRepository _repository;
  final ActivityLogGoalLinkRepository _linkRepository;

  /// Creates an [ActivityLogListCubit].
  ActivityLogListCubit({required ActivityLogGoalLinkRepository linkRepository})
      : _repository = ActivityLogRepository(linkRepo: linkRepository),
        _linkRepository = linkRepository,
        super(ActivityLogInitial()) {
    print('[CUBIT] ActivityLogListCubit created');
  }

  /// Loads all activity log entries and emits loading/success/error states.
  Future<void> loadActivities({bool runCleanup = false}) async {
    if (isClosed) return;
    print('[CUBIT] Starting loadActivities');
    emit(ActivityLogLoading());
    try {
      print('[CUBIT] Calling repository.getAllActivities()');
      final activities = await _repository.getAllActivities(runCleanup: runCleanup);
      print('[CUBIT] Repository returned ${activities.length} activities');
      print('[CUBIT] Activity IDs: ${activities.map((a) => a.id).toList()}');
      
      if (!isClosed) {
        print('[CUBIT] Emitting ActivityLogSuccess with ${activities.length} activities');
        emit(ActivityLogSuccess(activities));
        print('[CUBIT] State emitted successfully');
      } else {
        print('[CUBIT] Cubit is closed, not emitting state');
      }
    } catch (e) {
      print('[CUBIT] Error loading activities: $e');
      if (!isClosed) {
        emit(ActivityLogError('Could not load activities. Please try again.'));
      }
    }
  }

  /// Adds a new activity log entry and reloads the list.
  Future<void> addActivity(ActivityLogModel log) async {
    if (isClosed) return;
    try {
      await _repository.addActivity(log);
      await loadActivities();
      // Notify other cubits about the data change
      _notifyDataChanged('activity_added');
    } catch (e) {
      if (!isClosed) {
        emit(ActivityLogError('Could not add activity. Please try again.'));
      }
    }
  }

  /// Updates an existing activity log entry and reloads the list.
  Future<void> updateActivity(ActivityLogModel log) async {
    if (isClosed) return;
    try {
      await _repository.updateActivity(log);
      await loadActivities();
      // Notify other cubits about the data change
      _notifyDataChanged('activity_updated');
    } catch (e) {
      if (!isClosed) {
        emit(ActivityLogError('Could not update activity. Please try again.'));
      }
    }
  }

  /// Deletes an activity log entry and reloads the list.
  Future<void> deleteActivity(String id, {bool cleanupOrphanedLinks = false}) async {
    if (isClosed) {
      print('[CUBIT] Cubit is closed, cannot delete activity');
      return;
    }
    
    print('[CUBIT] Starting deletion of activity: $id');
    print('[CUBIT] Current state: ${state.runtimeType}');
    
    // Validate ID before attempting deletion
    if (id.isEmpty) {
      print('[CUBIT] Invalid activity ID (empty)');
      if (!isClosed) {
        emit(ActivityLogError('Invalid activity ID. Cannot delete activity.'));
      }
      return;
    }
    
    try {
      print('[CUBIT] Calling repository.deleteActivity($id)');
      // Delete the activity and all its links
      await _repository.deleteActivity(id, cleanupOrphanedLinks: cleanupOrphanedLinks);
      print('[CUBIT] Repository.deleteActivity completed successfully');
      
      print('[CUBIT] Now calling loadActivities() to refresh data');
      // Force reload the activities to ensure UI is updated
      await loadActivities();
      print('[CUBIT] loadActivities completed after deletion');
      
      // Notify other cubits about the data change
      _notifyDataChanged('activity_deleted', entityId: id);
      
    } catch (e) {
      print('[CUBIT] Error during deletion: $e');
      print('[CUBIT] Stack trace: ${StackTrace.current}');
      if (!isClosed) {
        // Provide more specific error messages
        String errorMessage = 'Could not delete activity.';
        if (e.toString().contains('not found') || e.toString().contains('No record found')) {
          errorMessage = 'Activity not found. It may have already been deleted.';
        } else if (e.toString().contains('database')) {
          errorMessage = 'Database error occurred. Please try again.';
        } else if (e.toString().contains('network') || e.toString().contains('connection')) {
          errorMessage = 'Connection error. Please check your internet connection.';
        }
        emit(ActivityLogError(errorMessage));
      }
    }
  }

  /// Checks if cleanup operations are needed without running them
  Future<Map<String, dynamic>> checkCleanupNeeded() async {
    if (isClosed) return {'needsCleanup': false, 'nullIdActivities': 0, 'orphanedLinks': 0, 'duplicateActivities': 0};
    try {
      return await _repository.checkCleanupNeeded();
    } catch (e) {
      print('[CUBIT] Error checking cleanup status: $e');
      return {'needsCleanup': false, 'nullIdActivities': 0, 'orphanedLinks': 0, 'duplicateActivities': 0};
    }
  }

  /// Manually triggers cleanup operations (should only be called when explicitly needed)
  Future<void> runCleanupOperations() async {
    if (isClosed) return;
    try {
      await _repository.runCleanupOperations();
      // Reload activities after cleanup
      await loadActivities();
    } catch (e) {
      if (!isClosed) {
        emit(ActivityLogError('Could not run cleanup operations. Please try again.'));
      }
    }
  }

  /// Links a goal to an activity log.
  Future<void> linkGoalToActivityLog(ActivityLogGoalLink link) async {
    await _linkRepository.linkGoalToActivityLog(link);
    // Optionally reload or emit new state
  }

  /// Unlinks a goal from an activity log.
  Future<void> unlinkGoalFromActivityLog(String linkId, {DateTime? unlinkedAt}) async {
    await _linkRepository.unlinkGoalFromActivityLog(linkId, unlinkedAt: unlinkedAt);
    // Optionally reload or emit new state
  }

  /// Fetches all goals linked to a specific activity log.
  Future<List<ActivityLogGoalLink>> getLinkedGoalsForActivityLog(String activityLogId) async {
    return await _linkRepository.getLinksForActivityLog(activityLogId);
  }

  /// Notifies other cubits that activity data has changed
  void _notifyDataChanged(String type, {String? entityId}) {
    print('[CUBIT] Notifying other cubits about data change: $type');
    // Use the global data sync service to notify other screens
    try {
      final dataSyncService = getIt<DataSyncService>();
      dataSyncService.notifyDataChanged(type, entityId: entityId);
    } catch (e) {
      print('[CUBIT] Error notifying data change: $e');
    }
  }

  @override
  Future<void> close() {
    print('[CUBIT] ActivityLogListCubit closing');
    return super.close();
  }
} 