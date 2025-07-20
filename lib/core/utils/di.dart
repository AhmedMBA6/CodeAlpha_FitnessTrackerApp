import 'package:get_it/get_it.dart';
import '../../features/activity_goals/data/repositories/activity_goal_repository.dart';
import '../../features/activity_log/data/repos/activity_log_repository.dart';
import '../../features/user_profile/data/repos/user_profile_repository.dart';
import '../../features/auth/data/authentication_repository.dart';
import '../../features/activity_goals/logic/cubit/goals_cubit.dart';
import '../../features/activity_log/data/repos/activity_log_goal_link_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register repositories as singletons
  getIt.registerLazySingleton<ActivityLogRepository>(() => ActivityLogRepository(linkRepo: SQLiteActivityLogGoalLinkRepository()));
  getIt.registerLazySingleton<UserProfileRepository>(() => UserProfileRepository());
  getIt.registerLazySingleton<AuthenticationRepository>(() => AuthenticationRepository());
  // Register in-memory repositories for current features only
  getIt.registerLazySingleton<ActivityLogGoalLinkRepository>(() => SQLiteActivityLogGoalLinkRepository());
  getIt.registerLazySingleton<ActivityGoalRepository>(() => ActivityGoalRepository());
  // Register GoalsCubit factory
  getIt.registerFactory<GoalsCubit>(() => GoalsCubit(
    goalRepo: getIt<ActivityGoalRepository>(),
    linkRepo: getIt<ActivityLogGoalLinkRepository>(),
    activityLogRepo: getIt<ActivityLogRepository>(),
  ));
} 