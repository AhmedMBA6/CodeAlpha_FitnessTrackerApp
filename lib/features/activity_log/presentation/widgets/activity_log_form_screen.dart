import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/activity_log_form_cubit.dart';
import '../../../activity_goals/data/repositories/activity_goal_repository.dart';
import '../../data/repos/activity_log_repository.dart';
import '../../data/repos/activity_log_goal_link_repository.dart';
import 'package:get_it/get_it.dart';
import 'steps/step1_type.dart';
import 'steps/step2_stats.dart';
import 'steps/step3_goals.dart';
import 'steps/step4_tags.dart';
import 'steps/step5_review.dart';
import '../../data/models/activity_log_model.dart';
import '../../../activity_goals/data/models/activity_goal.dart';

class ActivityLogFormScreen extends StatefulWidget {
  final ActivityLogModel? initialLog;
  final List<ActivityGoal>? initialGoals;
  const ActivityLogFormScreen({super.key, this.initialLog, this.initialGoals});

  @override
  State<ActivityLogFormScreen> createState() => _ActivityLogFormScreenState();
}

class _ActivityLogFormScreenState extends State<ActivityLogFormScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = ActivityLogFormCubit(
          goalRepository: GetIt.I<ActivityGoalRepository>(),
          logRepository: GetIt.I<ActivityLogRepository>(),
          linkRepository: GetIt.I<ActivityLogGoalLinkRepository>(),
          initialLog: widget.initialLog,
          initialGoals: widget.initialGoals,
        );
        // Load goals and tags after cubit creation
        cubit.loadGoalsAndTags();
        return cubit;
      },
      child: BlocConsumer<ActivityLogFormCubit, ActivityLogFormState>(
        listenWhen: (prev, curr) => curr.submitted && curr.newLogId != null,
        listener: (context, state) {
          if (state.submitted && state.newLogId != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => LiveActivityTrackerScreen(activityLogId: state.newLogId!),
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<ActivityLogFormCubit>();
          final isLastStep = state.currentStep.index == ActivityLogFormStep.values.length - 1;

          final availableGoals = state.availableGoals;
          final availableTags = state.availableTags;

          bool canContinue() {
            switch (state.currentStep) {
              case ActivityLogFormStep.selectType:
                return state.selectedType != null;
              case ActivityLogFormStep.inputStats:
                return state.duration != null && state.duration! > 0 && state.calories != null && state.calories! > 0;
              case ActivityLogFormStep.linkGoals:
                return true; // Optionally require at least one goal
              case ActivityLogFormStep.tagsNotes:
                return true;
              case ActivityLogFormStep.review:
                return true;
            }
          }

          void showValidationError(String message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('New Activity Log')),
            body: Stepper(
              type: StepperType.vertical,
              currentStep: state.currentStep.index,
              onStepContinue: () async {
                if (!canContinue()) {
                  // Show error for each step
                  switch (state.currentStep) {
                    case ActivityLogFormStep.selectType:
                      showValidationError('Please select an activity type.');
                      break;
                    case ActivityLogFormStep.inputStats:
                      if (state.duration == null || state.duration! <= 0) {
                        showValidationError('Please enter a valid duration.');
                      } else if (state.calories == null || state.calories! <= 0) {
                        showValidationError('Please enter calories burned.');
                      }
                      break;
                    case ActivityLogFormStep.linkGoals:
                      showValidationError('Please link at least one goal.');
                      break;
                    default:
                      showValidationError('Please complete this step.');
                  }
                  return;
                }
                if (!isLastStep) {
                  cubit.goToStep(ActivityLogFormStep.values[state.currentStep.index + 1]);
                } else {
                  await cubit.submit();
                  // Navigation handled in listener
                }
              },
              onStepCancel: () {
                if (state.currentStep.index > 0) {
                  cubit.goToStep(ActivityLogFormStep.values[state.currentStep.index - 1]);
                } else {
                  Navigator.of(context).pop();
                }
              },
              controlsBuilder: (context, details) {
                final canProceed = canContinue();
                // For Link Goals step, if no goals, show a button to navigate to Goals screen
                if (state.currentStep == ActivityLogFormStep.linkGoals && (availableGoals == null || availableGoals.isEmpty)) {
                  return Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/goals');
                        },
                        child: const Text('Create a Goal'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    if (state.currentStep.index > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: canProceed ? details.onStepContinue : null,
                      child: Text(isLastStep ? 'Start Activity' : 'Continue'),
                    ),
                  ],
                );
              },
              steps: [
                Step(
                  title: const Text('Select Activity Type'),
                  content: Step1Type(state: state, cubit: cubit),
                  isActive: state.currentStep == ActivityLogFormStep.selectType,
                ),
                Step(
                  title: const Text('Input Basic Stats'),
                  content: Step2Stats(state: state, cubit: cubit),
                  isActive: state.currentStep == ActivityLogFormStep.inputStats,
                ),
                Step(
                  title: const Text('Link Goals'),
                  content: Step3Goals(state: state, cubit: cubit, availableGoals: availableGoals),
                  isActive: state.currentStep == ActivityLogFormStep.linkGoals,
                ),
                Step(
                  title: const Text('Tags & Notes'),
                  content: Step4Tags(state: state, cubit: cubit, availableTags: availableTags),
                  isActive: state.currentStep == ActivityLogFormStep.tagsNotes,
                ),
                Step(
                  title: const Text('Review & Start'),
                  content: Step5Review(state: state, cubit: cubit),
                  isActive: state.currentStep == ActivityLogFormStep.review,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LiveActivityTrackerScreen extends StatelessWidget {
  final int activityLogId;
  const LiveActivityTrackerScreen({super.key, required this.activityLogId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Activity Tracker')),
      body: Center(
        child: Text('Tracking activity #$activityLogId...'),
      ),
    );
  }
} 