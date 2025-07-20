import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/activity_goal.dart';
import '../../../activity_log/data/models/activity_log_model.dart';
import '../../data/repositories/activity_goal_repository.dart';
import '../../../activity_log/data/repos/activity_log_repository.dart';

part 'goal_details_state.dart';

class GoalDetailsCubit extends Cubit<GoalDetailsState> {
  final ActivityGoalRepository goalRepository;
  final ActivityLogRepository logRepository;

  GoalDetailsCubit({
    required this.goalRepository,
    required this.logRepository,
  }) : super(GoalDetailsLoading());

  Future<void> loadGoalDetails(String goalId) async {
    emit(GoalDetailsLoading());
    try {
      final goals = await goalRepository.getAllGoals();
      final goal = goals.firstWhere((g) => g.id == goalId);
      final linkedActivities = await logRepository.getActivitiesForGoal(goalId);
      emit(GoalDetailsLoaded(goal: goal, linkedActivities: linkedActivities));
    } catch (e) {
      emit(GoalDetailsError(e.toString()));
    }
  }
} 