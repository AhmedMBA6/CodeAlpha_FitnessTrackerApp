part of 'activity_log_form_cubit.dart';

class ActivityLogFormState extends Equatable {
  final ActivityLogFormStep currentStep;
  final ActivityType? selectedType;
  final int? duration;
  final double? distance;
  final double? calories;
  final bool realTime;
  final List<ActivityGoal> linkedGoals;
  final List<String> tags;
  final String? notes;
  final bool submitted;
  final List<ActivityGoal> availableGoals;
  final List<String> availableTags;
  final int? newLogId;
  final bool submitting;
  final String? error;
  final String? successMessage;

  const ActivityLogFormState({
    required this.currentStep,
    this.selectedType,
    this.duration,
    this.distance,
    this.calories,
    this.realTime = false,
    this.linkedGoals = const [],
    this.tags = const [],
    this.notes,
    this.submitted = false,
    this.availableGoals = const [],
    this.availableTags = const [],
    this.newLogId,
    this.submitting = false,
    this.error,
    this.successMessage,
  });

  factory ActivityLogFormState.initial() => const ActivityLogFormState(
        currentStep: ActivityLogFormStep.selectType,
        submitting: false,
        error: null,
        successMessage: null,
      );

  ActivityLogFormState copyWith({
    ActivityLogFormStep? currentStep,
    ActivityType? selectedType,
    int? duration,
    double? distance,
    double? calories,
    bool? realTime,
    List<ActivityGoal>? linkedGoals,
    List<String>? tags,
    String? notes,
    bool? submitted,
    List<ActivityGoal>? availableGoals,
    List<String>? availableTags,
    int? newLogId,
    bool? submitting,
    String? error,
    String? successMessage,
  }) {
    return ActivityLogFormState(
      currentStep: currentStep ?? this.currentStep,
      selectedType: selectedType ?? this.selectedType,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      realTime: realTime ?? this.realTime,
      linkedGoals: linkedGoals ?? this.linkedGoals,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      submitted: submitted ?? this.submitted,
      availableGoals: availableGoals ?? this.availableGoals,
      availableTags: availableTags ?? this.availableTags,
      newLogId: newLogId ?? this.newLogId,
      submitting: submitting ?? this.submitting,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        selectedType,
        duration,
        distance,
        calories,
        realTime,
        linkedGoals,
        tags,
        notes,
        submitted,
        availableGoals,
        availableTags,
        newLogId,
        submitting,
        error,
        successMessage,
      ];
} 