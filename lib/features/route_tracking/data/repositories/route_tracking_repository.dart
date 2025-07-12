import 'dart:async';
import '../../../../core/utils/sqlite_helper.dart';
import '../models/route_point.dart';
import '../models/route_track.dart';

class RouteTrackingRepository {
  final SQLiteHelper _dbHelper = SQLiteHelper();

  // Get all saved routes
  Future<List<RouteTrack>> getAllRoutes() async {
    return await _dbHelper.getAllRoutes();
  }

  // Save a route
  Future<void> saveRoute(RouteTrack route) async {
    await _dbHelper.insertRoute(route);
    if (route.points.isNotEmpty) {
      await _dbHelper.insertRoutePoints(route.id, route.points);
    }
  }

  // Delete a route
  Future<void> deleteRoute(String routeId) async {
    await _dbHelper.deleteRoute(routeId);
  }

  // Get active route (currently being tracked)
  Future<RouteTrack?> getActiveRoute() async {
    return await _dbHelper.getActiveRoute();
  }

  // Save active route
  Future<void> saveActiveRoute(RouteTrack? route) async {
    await _dbHelper.saveActiveRoute(route);
  }

  // Update active route with new points
  Future<void> updateActiveRoute(List<RoutePoint> newPoints) async {
    final activeRoute = await getActiveRoute();
    if (activeRoute == null) return;

    final updatedRoute = activeRoute.copyWith(
      points: [...activeRoute.points, ...newPoints],
    );

    await saveActiveRoute(updatedRoute);
  }

  // Get routes by date range
  Future<List<RouteTrack>> getRoutesByDateRange(DateTime start, DateTime end) async {
    return await _dbHelper.getRoutesByDateRange(start, end);
  }

  // Get routes by activity type
  Future<List<RouteTrack>> getRoutesByActivityType(String activityType) async {
    return await _dbHelper.getRoutesByActivityType(activityType);
  }

  // Calculate route statistics
  Map<String, dynamic> calculateRouteStats(List<RouteTrack> routes) {
    if (routes.isEmpty) {
      return {
        'totalDistance': 0.0,
        'totalDuration': Duration.zero,
        'averageSpeed': 0.0,
        'maxSpeed': 0.0,
        'totalRoutes': 0,
      };
    }

    double totalDistance = 0.0;
    Duration totalDuration = Duration.zero;
    double maxSpeed = 0.0;
    double totalSpeed = 0.0;
    int speedCount = 0;

    for (final route in routes) {
      totalDistance += route.totalDistance;
      totalDuration += route.totalDuration;
      
      if (route.maxSpeed > maxSpeed) {
        maxSpeed = route.maxSpeed;
      }
      
      if (route.averageSpeed > 0) {
        totalSpeed += route.averageSpeed;
        speedCount++;
      }
    }

    return {
      'totalDistance': totalDistance,
      'totalDuration': totalDuration,
      'averageSpeed': speedCount > 0 ? totalSpeed / speedCount : 0.0,
      'maxSpeed': maxSpeed,
      'totalRoutes': routes.length,
    };
  }
} 