import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../activity_goals/data/models/activity_goal.dart';
import '../../activity_goals/data/repositories/activity_goal_repository.dart';
import '../data/models/activity_log_model.dart';
import '../data/repos/activity_log_repository.dart';
import '../data/repos/activity_log_goal_link_repository.dart';
import '../data/models/activity_log_goal_link.dart';
import 'package:uuid/uuid.dart';

part 'activity_log_form_state.dart';

enum ActivityLogFormStep { selectType, inputStats, linkGoals, tagsNotes, review }

enum ActivityType { run, walk, gym, yoga, custom }

/// ActivityLogFormCubit manages the state and logic for the multi-step activity log form.
/// It handles step navigation, validation, and submission of new activity logs.
class ActivityLogFormCubit extends Cubit<ActivityLogFormState> {
  final ActivityGoalRepository goalRepository;
  final ActivityLogRepository logRepository;
  final ActivityLogGoalLinkRepository linkRepository;

  ActivityLogFormCubit({
    required this.goalRepository,
    required this.logRepository,
    required this.linkRepository,
    ActivityLogModel? initialLog,
    List<ActivityGoal>? initialGoals,
  }) : super(
    initialLog != null && initialGoals != null
      ? ActivityLogFormState(
          currentStep: ActivityLogFormStep.selectType,
          selectedType: _activityTypeFromString(initialLog.activityType),
          duration: initialLog.duration,
          distance: initialLog.distance,
          calories: initialLog.calories,
          realTime: false,
          linkedGoals: initialGoals,
          tags: initialLog.tags ?? [],
          notes: null,
        )
      : ActivityLogFormState.initial(),
  );

  static ActivityType? _activityTypeFromString(String type) {
    return ActivityType.values.firstWhere(
      (t) => t.name.toLowerCase() == type.toLowerCase(),
      orElse: () => ActivityType.custom,
    );
  }

  /// Loads available goals and tags for the form.
  Future<void> loadGoalsAndTags() async {
    try {
      final goals = await goalRepository.getAllGoals();
      final tags = goals.expand((g) => g.tags ?? <String>[]).toSet().toList();
      // Check if cubit is still active before emitting
      if (!isClosed) {
        emit(state.copyWith(availableGoals: goals, availableTags: tags.cast<String>()));
      }
    } catch (e) {
      // Only emit error if cubit is still active
      if (!isClosed) {
        emit(state.copyWith(error: 'Failed to load goals: $e'));
      }
    }
  }

  /// Selects the activity type and advances to the next step.
  void selectActivityType(ActivityType type) {
    if (!isClosed) {
      emit(state.copyWith(selectedType: type));
    }
  }

  /// Inputs basic stats (duration, distance, calories) and advances to the next step.
  void inputStats({required int duration, double? distance, required double calories, bool realTime = false}) {
    if (!isClosed) {
      emit(state.copyWith(
        duration: duration,
        distance: distance,
        calories: calories,
        realTime: realTime,
      ));
    }
  }

  /// Links selected goals to the activity and advances to the next step.
  void linkGoals(List<ActivityGoal> goals) {
    if (!isClosed) {
      emit(state.copyWith(
        linkedGoals: goals,
      ));
    }
  }

  /// Sets tags and notes and advances to the review step.
  void setTagsAndNotes({required List<String> tags, String? notes}) {
    if (!isClosed) {
      emit(state.copyWith(
        tags: tags,
        notes: notes,
      ));
    }
  }

  /// Navigates to a specific step in the form.
  void goToStep(ActivityLogFormStep step) {
    if (!isClosed) {
      emit(state.copyWith(currentStep: step));
    }
  }

  /// Submits the completed activity log and saves goal links.
  Future<void> submit() async {
    if (isClosed) return;
    emit(state.copyWith(submitting: true, error: null, successMessage: null));
    try {
      // Construct ActivityLogModel
      final log = ActivityLogModel(
        activityType: state.selectedType?.name ?? 'custom',
        duration: state.duration ?? 0,
        calories: state.calories ?? 0,
        date: DateTime.now(),
        distance: state.distance,
        tags: state.tags,
        linkedGoalIds: state.linkedGoals.map((g) => g.id).toList(),
      );
      // Save log
      final logId = await logRepository.addActivity(log);
      // Save links
      for (final goal in state.linkedGoals) {
        await linkRepository.linkGoalToActivityLog(ActivityLogGoalLink(
          id: const Uuid().v4(),
          activityLogId: logId.toString(),
          goalId: goal.id,
          contributedValue: state.calories ?? 0,
          contributionType: goal.unit ?? 'custom',
          linkedAt: DateTime.now(),
        ));
      }
      // Check if cubit is still active before emitting success
      if (!isClosed) {
        emit(state.copyWith(submitting: false, submitted: true, newLogId: logId, successMessage: 'Activity log saved!'));
      }
    } catch (e) {
      // Only emit error if cubit is still active
      if (!isClosed) {
        emit(state.copyWith(submitting: false, error: e.toString()));
      }
    }
  }

  // Step validation methods (see implementation for details)
  bool isValidStep1() => state.selectedType != null;
  bool isValidStep2() => state.duration != null && state.duration! > 0 && state.calories != null && state.calories! > 0;
  bool isValidStep3() => state.linkedGoals.isNotEmpty;
  bool isValidStep4() => true; // Tags/notes are optional
  bool isFormValid() => isValidStep1() && isValidStep2() && isValidStep3() && isValidStep4();
} 