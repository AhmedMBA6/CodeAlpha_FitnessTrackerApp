import 'package:get_it/get_it.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/repos/activity_log_repository.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_log/data/repos/activity_log_goal_link_repository.dart';
import 'package:codealpha_fitness_tracker_app/features/activity_goals/data/repositories/activity_goal_repository.dart';
import 'package:codealpha_fitness_tracker_app/features/auth/data/authentication_repository.dart';
import 'package:codealpha_fitness_tracker_app/features/user_profile/data/repos/user_profile_repository.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/sqlite_helper.dart';
import 'dart:async';

final GetIt getIt = GetIt.instance;

/// Global event stream for data synchronization across the app
class DataSyncEvent {
  final String type; // 'activity_added', 'activity_updated', 'activity_deleted', 'goal_updated'
  final String? entityId;
  final DateTime timestamp;

  DataSyncEvent({
    required this.type,
    this.entityId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  final StreamController<DataSyncEvent> _eventController = StreamController<DataSyncEvent>.broadcast();

  Stream<DataSyncEvent> get events => _eventController.stream;

  void notifyDataChanged(String type, {String? entityId}) {
    final event = DataSyncEvent(type: type, entityId: entityId);
    _eventController.add(event);
    print('[DATA_SYNC] Notified data change: $type${entityId != null ? ' (ID: $entityId)' : ''}');
  }

  void dispose() {
    _eventController.close();
  }
}

void setupDependencies() {
  // Register the data sync service
  getIt.registerSingleton<DataSyncService>(DataSyncService());

  // Register SQLite helper
  getIt.registerSingleton<SQLHelper>(SQLHelper());

  // Register authentication repository
  getIt.registerSingleton<AuthenticationRepository>(AuthenticationRepository());

  // Register user profile repository
  getIt.registerSingleton<UserProfileRepository>(UserProfileRepository());

  // Register repositories
  getIt.registerSingleton<ActivityLogGoalLinkRepository>(
    SQLiteActivityLogGoalLinkRepository(dbHelper: getIt<SQLHelper>()),
  );

  getIt.registerSingleton<ActivityLogRepository>(
    ActivityLogRepository(
      dbHelper: getIt<SQLHelper>(),
      linkRepo: getIt<ActivityLogGoalLinkRepository>(),
    ),
  );

  getIt.registerSingleton<ActivityGoalRepository>(
    ActivityGoalRepository(),
  );
} 