import 'package:equatable/equatable.dart';
import '../../data/models/route_track.dart';

enum RouteTrackingStatus {
  initial,
  loading,
  success,
  failure,
  tracking,
  paused,
}

class RouteTrackingState extends Equatable {
  final RouteTrackingStatus status;
  final List<RouteTrack> routes;
  final List<RouteTrack>? filteredRoutes;
  final RouteTrack? activeRoute;
  final String? errorMessage;

  const RouteTrackingState({
    required this.status,
    required this.routes,
    this.filteredRoutes,
    this.activeRoute,
    this.errorMessage,
  });

  const RouteTrackingState.initial()
      : status = RouteTrackingStatus.initial,
        routes = const [],
        filteredRoutes = null,
        activeRoute = null,
        errorMessage = null;

  RouteTrackingState copyWith({
    RouteTrackingStatus? status,
    List<RouteTrack>? routes,
    List<RouteTrack>? filteredRoutes,
    RouteTrack? activeRoute,
    String? errorMessage,
  }) {
    return RouteTrackingState(
      status: status ?? this.status,
      routes: routes ?? this.routes,
      filteredRoutes: filteredRoutes ?? this.filteredRoutes,
      activeRoute: activeRoute ?? this.activeRoute,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<RouteTrack> get displayRoutes {
    return filteredRoutes ?? routes;
  }

  bool get isTracking => status == RouteTrackingStatus.tracking;
  bool get isPaused => status == RouteTrackingStatus.paused;
  bool get hasActiveRoute => activeRoute != null;

  @override
  List<Object?> get props => [
        status,
        routes,
        filteredRoutes,
        activeRoute,
        errorMessage,
      ];
} 