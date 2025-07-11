import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../activity_log/data/repos/activity_log_repository.dart';
import '../data/dashboard_aggregator.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final ActivityLogRepository _activityLogRepository;

  DashboardCubit(this._activityLogRepository) : super(DashboardInitial());

  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    try {
      final logs = await _activityLogRepository.getAllActivities();
      final todaySummary = DashboardAggregator.getTodaySummary(logs);
      final weeklySummaries = DashboardAggregator.getWeeklySummary(logs);
      emit(DashboardLoaded(todaySummary: todaySummary, weeklySummaries: weeklySummaries));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
} 