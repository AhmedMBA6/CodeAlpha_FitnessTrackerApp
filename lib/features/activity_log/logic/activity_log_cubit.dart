
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/activity_log_model.dart';
import '../data/repos/activity_log_repository.dart';

part 'activity_log_state.dart';

class ActivityLogCubit extends Cubit<ActivityLogState> {
  final ActivityLogRepository _repository;

  ActivityLogCubit(this._repository) : super(ActivityLogInitial());

  Future<void> loadActivities() async {
    emit(ActivityLogLoading());
    try {
      final activities = await _repository.getAllActivities();
      emit(ActivityLogSuccess(activities));
    } catch (e) {
      emit(ActivityLogError(e.toString()));
    }
  }

  Future<void> addActivity(ActivityLogModel log) async {
    try {
      await _repository.addActivity(log);
      loadActivities();
    } catch (e) {
      emit(ActivityLogError(e.toString()));
    }
  }

  Future<void> updateActivity(ActivityLogModel log) async {
    try {
      await _repository.updateActivity(log);
      loadActivities();
    } catch (e) {
      emit(ActivityLogError(e.toString()));
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      await _repository.deleteActivity(id);
      loadActivities();
    } catch (e) {
      emit(ActivityLogError(e.toString()));
    }
  }
} 