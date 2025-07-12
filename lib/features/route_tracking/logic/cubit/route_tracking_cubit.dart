import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/route_point.dart';
import '../../data/models/route_track.dart';
import '../../data/repositories/route_tracking_repository.dart';
import 'route_tracking_state.dart';

class RouteTrackingCubit extends Cubit<RouteTrackingState> {
  final RouteTrackingRepository _repository;
  StreamSubscription<Position>? _locationSubscription;
  Timer? _updateTimer;

  RouteTrackingCubit({required RouteTrackingRepository repository})
      : _repository = repository,
        super(const RouteTrackingState.initial());

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _updateTimer?.cancel();
    return super.close();
  }

  // Load all saved routes
  Future<void> loadRoutes() async {
    emit(state.copyWith(status: RouteTrackingStatus.loading));
    
    try {
      final routes = await _repository.getAllRoutes();
      emit(state.copyWith(
        status: RouteTrackingStatus.success,
        routes: routes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RouteTrackingStatus.failure,
        errorMessage: 'Failed to load routes: $e',
      ));
    }
  }

  // Robust check and request for location permissions using Geolocator
  Future<bool> ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      emit(state.copyWith(
        status: RouteTrackingStatus.failure,
        errorMessage: 'Location services are disabled. Please enable them to track routes.',
      ));
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(state.copyWith(
          status: RouteTrackingStatus.failure,
          errorMessage: 'Location permission is required to track routes',
        ));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      emit(state.copyWith(
        status: RouteTrackingStatus.failure,
        errorMessage: 'Location permissions are permanently denied. Please enable them from settings.',
      ));
      return false;
    }
    // Permissions granted
    return true;
  }

  // Start tracking a new route
  Future<void> startTracking({
    required String name,
    required String activityType,
  }) async {
    final hasPermission = await ensureLocationPermission();
    if (!hasPermission) {
      return;
    }

    try {
      // Create new route
      final newRoute = RouteTrack(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        startTime: DateTime.now(),
        points: [],
        totalDistance: 0.0,
        totalDuration: Duration.zero,
        averageSpeed: 0.0,
        maxSpeed: 0.0,
        activityType: activityType,
      );

      // Save as active route
      await _repository.saveActiveRoute(newRoute);
      
      // Start location tracking
      await _startLocationTracking();
      
      emit(state.copyWith(
        status: RouteTrackingStatus.tracking,
        activeRoute: newRoute,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RouteTrackingStatus.failure,
        errorMessage: 'Failed to start tracking: $e',
      ));
    }
  }

  // Stop tracking current route
  Future<void> stopTracking() async {
    if (state.activeRoute == null) return;

    try {
      _locationSubscription?.cancel();
      _updateTimer?.cancel();

      final completedRoute = state.activeRoute!.copyWith(
        endTime: DateTime.now(),
        totalDistance: state.activeRoute!.currentDistance,
        totalDuration: state.activeRoute!.currentDuration,
        pausedDuration: Duration.zero,
        lastPausedTime: null,
      );

      // Save completed route
      await _repository.saveRoute(completedRoute);
      await _repository.saveActiveRoute(null);

      // Reload routes list
      final routes = await _repository.getAllRoutes();

      emit(state.copyWith(
        status: RouteTrackingStatus.success,
        activeRoute: null,
        routes: routes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RouteTrackingStatus.failure,
        errorMessage: 'Failed to stop tracking: $e',
      ));
    }
  }

  // Pause tracking
  Future<void> pauseTracking() async {
    if (state.activeRoute == null) return;
    _locationSubscription?.cancel();
    _updateTimer?.cancel();
    final now = DateTime.now();
    final updatedRoute = state.activeRoute!.copyWith(
      lastPausedTime: now,
    );
    await _repository.saveActiveRoute(updatedRoute);
    emit(state.copyWith(
      status: RouteTrackingStatus.paused,
      activeRoute: updatedRoute,
    ));
  }

  // Resume tracking
  Future<void> resumeTracking() async {
    if (state.activeRoute == null) return;
    final now = DateTime.now();
    final lastPaused = state.activeRoute!.lastPausedTime;
    Duration paused = Duration.zero;
    if (lastPaused != null) {
      paused = now.difference(lastPaused);
    }
    final updatedRoute = state.activeRoute!.copyWith(
      pausedDuration: state.activeRoute!.pausedDuration + paused,
      lastPausedTime: null,
    );
    await _repository.saveActiveRoute(updatedRoute);
    await _startLocationTracking();
    emit(state.copyWith(
      status: RouteTrackingStatus.tracking,
      activeRoute: updatedRoute,
    ));
  }

  // Delete a route
  Future<void> deleteRoute(String routeId) async {
    try {
      await _repository.deleteRoute(routeId);
      final routes = await _repository.getAllRoutes();
      
      emit(state.copyWith(routes: routes));
    } catch (e) {
      emit(state.copyWith(
        status: RouteTrackingStatus.failure,
        errorMessage: 'Failed to delete route: $e',
      ));
    }
  }

  // Get routes by date range
  Future<void> getRoutesByDateRange(DateTime start, DateTime end) async {
    try {
      final routes = await _repository.getRoutesByDateRange(start, end);
      emit(state.copyWith(
        filteredRoutes: routes,
        status: RouteTrackingStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RouteTrackingStatus.failure,
        errorMessage: 'Failed to filter routes: $e',
      ));
    }
  }

  // Get routes by activity type
  Future<void> getRoutesByActivityType(String activityType) async {
    try {
      final routes = await _repository.getRoutesByActivityType(activityType);
      emit(state.copyWith(
        filteredRoutes: routes,
        status: RouteTrackingStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RouteTrackingStatus.failure,
        errorMessage: 'Failed to filter routes: $e',
      ));
    }
  }

  // Clear filters
  void clearFilters() {
    emit(state.copyWith(filteredRoutes: null));
  }

  // Start location tracking
  Future<void> _startLocationTracking() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _addLocationPoint(position);
      },
      onError: (error) {
        emit(state.copyWith(
          status: RouteTrackingStatus.failure,
          errorMessage: 'Location error: $error',
        ));
      },
    );

    // Update timer for real-time stats
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.activeRoute != null) {
        emit(state.copyWith()); // Trigger rebuild for real-time updates
      }
    });
  }

  // Add new location point to active route
  Future<void> _addLocationPoint(Position position) async {
    if (state.activeRoute == null) return;

    final routePoint = RoutePoint(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
      speed: position.speed,
      altitude: position.altitude,
      accuracy: position.accuracy,
    );

    final updatedRoute = state.activeRoute!.copyWith(
      points: [...state.activeRoute!.points, routePoint],
    );

    await _repository.saveActiveRoute(updatedRoute);

    emit(state.copyWith(activeRoute: updatedRoute));
  }

  // Load active route on app start
  Future<void> loadActiveRoute() async {
    try {
      final activeRoute = await _repository.getActiveRoute();
      if (activeRoute != null) {
        emit(state.copyWith(
          activeRoute: activeRoute,
          status: RouteTrackingStatus.paused, // Assume paused on app restart
        ));
      }
    } catch (e) {
      // Ignore errors when loading active route
    }
  }
} 