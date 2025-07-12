import '../models/activity_goal.dart';
import '../../../route_tracking/data/models/route_point.dart';
import '../../../../core/utils/sqlite_helper.dart';

class ActivityGoalRepository {
  final SQLiteHelper _sqliteHelper;

  ActivityGoalRepository({SQLiteHelper? sqliteHelper}) 
      : _sqliteHelper = sqliteHelper ?? SQLiteHelper();

  /// Creates a distance-based goal
  ActivityGoal createDistanceGoal({
    required double distanceInMeters,
    String? description,
  }) {
    return ActivityGoal.distance(
      distanceInMeters: distanceInMeters,
      description: description,
    );
  }

  /// Creates a destination-based goal
  ActivityGoal createDestinationGoal({
    required RoutePoint destination,
    String? description,
  }) {
    return ActivityGoal.destination(
      destination: destination,
      description: description,
    );
  }

  /// Validates a goal
  bool isValidGoal(ActivityGoal goal) {
    return goal.isValid;
  }

  /// Saves a goal to a route (this is handled by the route tracking repository)
  /// This method is provided for future extensibility if we need to store goals separately
  Future<void> saveGoal(ActivityGoal goal, String routeId) async {
    // For now, goals are stored as part of the route
    // This method can be extended if we need separate goal storage
  }

  /// Retrieves a goal from a route
  Future<ActivityGoal?> getGoalForRoute(String routeId) async {
    final route = await _sqliteHelper.getRouteById(routeId);
    return route?.goal;
  }

  /// Updates a goal for a route
  Future<void> updateGoalForRoute(String routeId, ActivityGoal goal) async {
    final route = await _sqliteHelper.getRouteById(routeId);
    if (route != null) {
      final updatedRoute = route.copyWith(goal: goal);
      await _sqliteHelper.updateRoute(updatedRoute);
    }
  }

  /// Deletes a goal from a route
  Future<void> deleteGoalFromRoute(String routeId) async {
    final route = await _sqliteHelper.getRouteById(routeId);
    if (route != null) {
      final updatedRoute = route.copyWith(goal: null);
      await _sqliteHelper.updateRoute(updatedRoute);
    }
  }

  /// Gets all routes with goals
  Future<List<Map<String, dynamic>>> getRoutesWithGoals() async {
    final routes = await _sqliteHelper.getAllRoutes();
    return routes
        .where((route) => route.goal != null)
        .map((route) => {
              'routeId': route.id,
              'routeName': route.name,
              'goal': route.goal!,
              'isGoalReached': route.isGoalReached,
              'goalProgress': route.goalProgress,
            })
        .toList();
  }

  /// Gets routes with completed goals
  Future<List<Map<String, dynamic>>> getRoutesWithCompletedGoals() async {
    final routes = await _sqliteHelper.getAllRoutes();
    return routes
        .where((route) => route.goal != null && route.isGoalReached)
        .map((route) => {
              'routeId': route.id,
              'routeName': route.name,
              'goal': route.goal!,
              'completionTime': route.endTime,
            })
        .toList();
  }

  /// Gets routes with pending goals
  Future<List<Map<String, dynamic>>> getRoutesWithPendingGoals() async {
    final routes = await _sqliteHelper.getAllRoutes();
    return routes
        .where((route) => route.goal != null && !route.isGoalReached)
        .map((route) => {
              'routeId': route.id,
              'routeName': route.name,
              'goal': route.goal!,
              'goalProgress': route.goalProgress,
            })
        .toList();
  }

  /// Gets goal statistics
  Future<Map<String, dynamic>> getGoalStatistics() async {
    final routes = await _sqliteHelper.getAllRoutes();
    final routesWithGoals = routes.where((route) => route.goal != null).toList();
    
    if (routesWithGoals.isEmpty) {
      return {
        'totalGoals': 0,
        'completedGoals': 0,
        'pendingGoals': 0,
        'completionRate': 0.0,
        'averageProgress': 0.0,
      };
    }

    final completedGoals = routesWithGoals.where((route) => route.isGoalReached).length;
    final totalProgress = routesWithGoals.fold<double>(0.0, (sum, route) => sum + route.goalProgress);
    final averageProgress = totalProgress / routesWithGoals.length;

    return {
      'totalGoals': routesWithGoals.length,
      'completedGoals': completedGoals,
      'pendingGoals': routesWithGoals.length - completedGoals,
      'completionRate': completedGoals / routesWithGoals.length,
      'averageProgress': averageProgress,
    };
  }
} 