
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
  final ActivityLogRepository _repository = getIt<ActivityLogRepository>();
  final ActivityLogGoalLinkRepository _linkRepository;

  /// Creates an [ActivityLogListCubit].
  ActivityLogListCubit({required ActivityLogGoalLinkRepository linkRepository})
      : _linkRepository = linkRepository,
        super(ActivityLogInitial());

  /// Loads all activity log entries and emits loading/success/error states.
  Future<void> loadActivities() async {
    if (isClosed) return;
    emit(ActivityLogLoading());
    try {
      final activities = await _repository.getAllActivities();
      if (!isClosed) {
        emit(ActivityLogSuccess(activities));
      }
    } catch (e) {
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
      loadActivities();
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
      loadActivities();
    } catch (e) {
      if (!isClosed) {
        emit(ActivityLogError('Could not update activity. Please try again.'));
      }
    }
  }

  /// Deletes an activity log entry and reloads the list.
  Future<void> deleteActivity(String id) async {
    if (isClosed) return;
    try {
      await _repository.deleteActivity(id);
      loadActivities();
    } catch (e) {
      if (!isClosed) {
        emit(ActivityLogError('Could not delete activity. Please try again.'));
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
} 