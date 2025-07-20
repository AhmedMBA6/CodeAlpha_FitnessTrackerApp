import 'package:flutter/material.dart';
import '../../../activity_goals/data/models/activity_goal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/activity_log_form_cubit.dart';
import 'steps/step1_type.dart';
import 'steps/step2_stats.dart';
import 'steps/step3_goals.dart';
import 'steps/step4_tags.dart';
import 'steps/step5_review.dart';

class NewActivityLogForm extends StatelessWidget {
  final List<ActivityGoal> availableGoals;
  final void Function()? onSaved;
  const NewActivityLogForm({super.key, required this.availableGoals, this.onSaved});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityLogFormCubit, ActivityLogFormState>(
      builder: (context, state) {
        final cubit = context.read<ActivityLogFormCubit>();
        return Stepper(
          type: StepperType.vertical,
          currentStep: state.currentStep.index,
          onStepContinue: () async {
            if (state.currentStep.index < ActivityLogFormStep.values.length - 1) {
              cubit.goToStep(ActivityLogFormStep.values[state.currentStep.index + 1]);
            } else {
              await cubit.submit();
              if (onSaved != null) onSaved!();
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
            final isLastStep = state.currentStep.index == ActivityLogFormStep.values.length - 1;
            return Row(
              children: [
                if (state.currentStep.index > 0)
                  Semantics(
                    label: 'Back',
                    button: true,
                    child: Tooltip(
                      message: 'Go to previous step',
                      child: TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Semantics(
                  label: isLastStep ? 'Start Activity' : 'Next',
                  button: true,
                  child: Tooltip(
                    message: isLastStep ? 'Submit and start activity' : 'Go to next step',
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(isLastStep ? 'Start Activity' : 'Next'),
                    ),
                  ),
                ),
              ],
            );
          },
          steps: [
            Step(
              title: const Text('Activity Type'),
              isActive: state.currentStep.index >= 0,
              content: Step1Type(state: state, cubit: cubit),
            ),
            Step(
              title: const Text('Basic Stats'),
              isActive: state.currentStep.index >= 1,
              content: Step2Stats(state: state, cubit: cubit),
            ),
            Step(
              title: const Text('Link Goals'),
              isActive: state.currentStep.index >= 2,
              content: Step3Goals(state: state, cubit: cubit, availableGoals: availableGoals),
            ),
            Step(
              title: const Text('Tags & Notes'),
              isActive: state.currentStep.index >= 3,
              content: Step4Tags(state: state, cubit: cubit, availableTags: state.availableTags),
            ),
            Step(
              title: const Text('Review & Start'),
              isActive: state.currentStep.index >= 4,
              content: Step5Review(state: state, cubit: cubit),
            ),
          ],
        );
      },
    );
  }
} 