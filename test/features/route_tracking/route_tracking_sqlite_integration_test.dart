import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:codealpha_fitness_tracker_app/features/route_tracking/data/repositories/route_tracking_repository.dart';
import 'package:codealpha_fitness_tracker_app/features/route_tracking/data/models/route_track.dart';
import 'package:codealpha_fitness_tracker_app/features/route_tracking/data/models/route_point.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/sqlite_helper.dart';

void main() {
  group('Route Tracking SQLite Integration Tests', () {
    late RouteTrackingRepository repository;

    setUpAll(() {
      // Initialize SQLite FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      repository = RouteTrackingRepository();
      final db = await SQLiteHelper().database;
      await db.delete('route_points');
      await db.delete('routes');
      await db.delete('active_routes');
    });

    test('should save and retrieve a route', () async {
      // Create a test route
      final route = RouteTrack(
        id: 'test-route-1',
        name: 'Test Route',
        startTime: DateTime.now(),
        points: [
          RoutePoint(
            latitude: 40.7128,
            longitude: -74.0060,
            timestamp: DateTime.now(),
            speed: 5.0,
            altitude: 10.0,
            accuracy: 5.0,
          ),
          RoutePoint(
            latitude: 40.7129,
            longitude: -74.0061,
            timestamp: DateTime.now().add(const Duration(seconds: 10)),
            speed: 6.0,
            altitude: 12.0,
            accuracy: 4.0,
          ),
        ],
        totalDistance: 100.0,
        totalDuration: const Duration(minutes: 5),
        averageSpeed: 5.5,
        maxSpeed: 6.0,
        activityType: 'Running',
      );

      // Save the route
      await repository.saveRoute(route);

      // Retrieve all routes
      final routes = await repository.getAllRoutes();

      // Verify the route was saved
      expect(routes.length, 1);
      expect(routes.first.id, 'test-route-1');
      expect(routes.first.name, 'Test Route');
      expect(routes.first.points.length, 2);
      expect(routes.first.totalDistance, 100.0);
      expect(routes.first.activityType, 'Running');
    });

    test('should save and retrieve active route', () async {
      // Create an active route
      final activeRoute = RouteTrack(
        id: 'active-route-1',
        name: 'Active Route',
        startTime: DateTime.now(),
        points: [
          RoutePoint(
            latitude: 40.7128,
            longitude: -74.0060,
            timestamp: DateTime.now(),
          ),
        ],
        totalDistance: 50.0,
        totalDuration: const Duration(minutes: 2),
        averageSpeed: 4.0,
        maxSpeed: 5.0,
        activityType: 'Walking',
      );

      // Save as active route
      await repository.saveActiveRoute(activeRoute);

      // Retrieve active route
      final retrievedRoute = await repository.getActiveRoute();

      // Verify the active route was saved
      expect(retrievedRoute, isNotNull);
      expect(retrievedRoute!.id, 'active-route-1');
      expect(retrievedRoute.name, 'Active Route');
      expect(retrievedRoute.points.length, 1);
      expect(retrievedRoute.activityType, 'Walking');

      // Clear active route
      await repository.saveActiveRoute(null);

      // Verify active route was cleared
      final clearedRoute = await repository.getActiveRoute();
      expect(clearedRoute, isNull);
    });

    test('should delete a route', () async {
      // Create and save a route
      final route = RouteTrack(
        id: 'delete-test-route',
        name: 'Delete Test Route',
        startTime: DateTime.now(),
        points: [],
        totalDistance: 200.0,
        totalDuration: const Duration(minutes: 10),
        averageSpeed: 3.0,
        maxSpeed: 4.0,
        activityType: 'Cycling',
      );

      await repository.saveRoute(route);

      // Verify route was saved
      final routesBefore = await repository.getAllRoutes();
      expect(routesBefore.length, 1);

      // Delete the route
      await repository.deleteRoute('delete-test-route');

      // Verify route was deleted
      final routesAfter = await repository.getAllRoutes();
      expect(routesAfter.length, 0);
    });

    test('should filter routes by activity type', () async {
      // Create routes with different activity types
      final runningRoute = RouteTrack(
        id: 'running-route',
        name: 'Running Route',
        startTime: DateTime.now(),
        points: [],
        totalDistance: 100.0,
        totalDuration: const Duration(minutes: 5),
        averageSpeed: 5.0,
        maxSpeed: 6.0,
        activityType: 'Running',
      );

      final walkingRoute = RouteTrack(
        id: 'walking-route',
        name: 'Walking Route',
        startTime: DateTime.now(),
        points: [],
        totalDistance: 50.0,
        totalDuration: const Duration(minutes: 10),
        averageSpeed: 2.5,
        maxSpeed: 3.0,
        activityType: 'Walking',
      );

      // Save both routes
      await repository.saveRoute(runningRoute);
      await repository.saveRoute(walkingRoute);

      // Filter by running
      final runningRoutes = await repository.getRoutesByActivityType('Running');
      expect(runningRoutes.length, 1);
      expect(runningRoutes.first.activityType, 'Running');

      // Filter by walking
      final walkingRoutes = await repository.getRoutesByActivityType('Walking');
      expect(walkingRoutes.length, 1);
      expect(walkingRoutes.first.activityType, 'Walking');
    });

    test('should calculate route statistics', () async {
      // Create multiple routes
      final route1 = RouteTrack(
        id: 'route-1',
        name: 'Route 1',
        startTime: DateTime.now(),
        points: [],
        totalDistance: 100.0,
        totalDuration: const Duration(minutes: 5),
        averageSpeed: 5.0,
        maxSpeed: 6.0,
        activityType: 'Running',
      );

      final route2 = RouteTrack(
        id: 'route-2',
        name: 'Route 2',
        startTime: DateTime.now(),
        points: [],
        totalDistance: 200.0,
        totalDuration: const Duration(minutes: 10),
        averageSpeed: 4.0,
        maxSpeed: 5.0,
        activityType: 'Running',
      );

      // Save routes
      await repository.saveRoute(route1);
      await repository.saveRoute(route2);

      // Get all routes
      final routes = await repository.getAllRoutes();

      // Calculate statistics
      final stats = repository.calculateRouteStats(routes);

      // Verify statistics
      expect(stats['totalDistance'], 300.0);
      expect(stats['totalRoutes'], 2);
      expect(stats['maxSpeed'], 6.0);
      expect(stats['averageSpeed'], 4.5); // (5.0 + 4.0) / 2
    });
  });
} 