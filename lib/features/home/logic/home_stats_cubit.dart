
import 'package:equatable/equatable.dart';
import 'dart:math' as math;
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/repos/activity_log_goal_link_repository.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_goals/data/repositories/activity_goal_repository.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/data/dashboard_aggregator.dart';
import 'package:codealpha_fitness_tracker_app/features/dashboard/data/dashboard_filter_service.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/repos/activity_log_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/di.dart';
import 'dart:async';

part 'home_stats_state.dart';

class HomeStatsCubit extends Cubit<HomeStatsState> {
  HomeStatsCubit() : super(HomeStatsLoading()) {
    // Listen for data changes and refresh stats
    _setupDataSyncListener();
  }

  StreamSubscription<DataSyncEvent>? _dataSyncSubscription;

  void _setupDataSyncListener() {
    try {
      final dataSyncService = getIt<DataSyncService>();
      _dataSyncSubscription = dataSyncService.events.listen((event) {
        print('[HOME_STATS] Received data sync event: ${event.type}');
        // Refresh stats when activity data changes
        if (event.type == 'activity_added' || 
            event.type == 'activity_updated' || 
            event.type == 'activity_deleted') {
          fetchStats();
        }
      });
    } catch (e) {
      print('[HOME_STATS] Error setting up data sync listener: $e');
    }
  }

  @override
  Future<void> close() {
    _dataSyncSubscription?.cancel();
    return super.close();
  }

  Future<void> fetchStats() async {
    if (isClosed) return;
    emit(HomeStatsLoading());
    try {
      final logs = await ActivityLogRepository(linkRepo: SQLiteActivityLogGoalLinkRepository()).getAllActivities();
      final todayLogs = DashboardFilterService.getTodayLogs(logs);
      final todaySummary = DashboardAggregator.getTodaySummary(logs);
      final totalCalories = todaySummary.totalCalories;
      final totalDistance = todayLogs.fold<double>(0.0, (sum, log) => sum + (log.distance ?? 0.0));
      final goalStats = await ActivityGoalRepository().getGoalStatistics();
      final activeGoals = goalStats['pendingGoals'] ?? 0;
      final progress = activeGoals > 0 ? math.min(1.0, (goalStats['averageProgress'] ?? 0.0)) : 0.0;
      if (!isClosed) {
        emit(HomeStatsLoaded(
          calories: totalCalories,
          distance: totalDistance,
          activeGoals: activeGoals,
          progress: progress,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(HomeStatsError(e.toString()));
      }
    }
  }
} 