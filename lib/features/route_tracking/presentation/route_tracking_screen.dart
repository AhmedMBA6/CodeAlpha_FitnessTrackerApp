import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../logic/cubit/route_tracking_cubit.dart';
import '../logic/cubit/route_tracking_state.dart';
import '../data/models/route_track.dart';
import 'widgets/tracking_controls.dart';
import 'widgets/route_stats_card.dart';
import 'widgets/route_history_list.dart';
import 'package:geolocator/geolocator.dart';
import 'route_details_screen.dart';

class RouteTrackingScreen extends StatefulWidget {
  const RouteTrackingScreen({super.key});

  @override
  State<RouteTrackingScreen> createState() => _RouteTrackingScreenState();
}

class _RouteTrackingScreenState extends State<RouteTrackingScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _moveCameraToUserLocation();
    });
  }

  Future<void> _loadInitialData() async {
    final cubit = context.read<RouteTrackingCubit>();
    await cubit.loadRoutes();
    await cubit.loadActiveRoute();
  }

  Future<void> _moveCameraToUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('user_location'),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: const InfoWindow(title: 'You are here'),
          ),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Route Tracking'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: BlocConsumer<RouteTrackingCubit, RouteTrackingState>(
          listener: (context, state) {
            if (state.status == RouteTrackingStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateMapForState(state);
              // Move camera to latest point if tracking
              if (state.isTracking && state.activeRoute != null && state.activeRoute!.points.isNotEmpty && _mapController != null) {
                final lastPoint = state.activeRoute!.points.last;
                _mapController!.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(lastPoint.latitude, lastPoint.longitude),
                  ),
                );
              }
            });
            return Column(
              children: [
                // Map Section
                Expanded(
                  flex: 2,
                  child: _buildMapSection(state),
                ),
                // Stats and Controls Section
                Expanded(
                  flex: 1,
                  child: _buildBottomSection(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapSection(RouteTrackingState state) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0), // Will be updated when tracking starts
            zoom: 15,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _updateMapForState(state);
            _moveCameraToUserLocation();
          },
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  Widget _buildBottomSection(RouteTrackingState state) {
    if (state.hasActiveRoute) {
      // When tracking, scrollable for stats/controls only
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              RouteStatsCard(route: state.activeRoute!),
              const SizedBox(height: 16),
              TrackingControls(
                isTracking: state.isTracking,
                isPaused: state.isPaused,
                hasActiveRoute: state.hasActiveRoute,
                onStartTracking: _showStartTrackingDialog,
                onStopTracking: _stopTracking,
                onPauseTracking: _pauseTracking,
                onResumeTracking: _resumeTracking,
              ),
            ],
          ),
        ),
      );
    } else {
      // When not tracking, let history list fill space and scroll
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TrackingControls(
                isTracking: state.isTracking,
                isPaused: state.isPaused,
                hasActiveRoute: state.hasActiveRoute,
                onStartTracking: _showStartTrackingDialog,
                onStopTracking: _stopTracking,
                onPauseTracking: _pauseTracking,
                onResumeTracking: _resumeTracking,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RouteHistoryList(
                  routes: state.displayRoutes,
                  onRouteTap: _showRouteDetails,
                  onRouteDelete: _deleteRoute,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _updateMapForState(RouteTrackingState state) {
    if (state.activeRoute != null && state.activeRoute!.points.isNotEmpty) {
      _updateMapWithRoute(state.activeRoute!);
    }
  }

  void _updateMapWithRoute(RouteTrack route) {
    if (route.points.isEmpty) return;

    // Create polyline from route points
    final polylinePoints = route.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    _polylines = {
      Polyline(
        polylineId: const PolylineId('active_route'),
        points: polylinePoints,
        color: Colors.blue,
        width: 4,
      ),
    };

    // Create markers for start and end points
    _markers = {};

    if (route.points.isNotEmpty) {
      final startPoint = route.points.first;
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: LatLng(startPoint.latitude, startPoint.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'Start'),
        ),
      );
    }

    if (route.points.length > 1) {
      final endPoint = route.points.last;
      _markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(endPoint.latitude, endPoint.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Current Position'),
        ),
      );
    }

    // Move camera to show the route
    if (_mapController != null && polylinePoints.isNotEmpty) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(_getBounds(polylinePoints), 50.0),
      );
    }
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (final point in points) {
      minLat = minLat == null ? point.latitude : min(minLat, point.latitude);
      maxLat = maxLat == null ? point.latitude : max(maxLat, point.latitude);
      minLng = minLng == null ? point.longitude : min(minLng, point.longitude);
      maxLng = maxLng == null ? point.longitude : max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  void _showStartTrackingDialog() {
    final cubit = context.read<RouteTrackingCubit>();
    showDialog(
      context: context,
      builder: (context) => _StartTrackingDialog(
        onStartTracking: (name, activityType) {
          cubit.startTracking(name: name, activityType: activityType);
        },
      ),
    );
  }

  void _stopTracking() {
    final cubit = context.read<RouteTrackingCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Tracking'),
        content: const Text('Are you sure you want to stop tracking this route?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await cubit.stopTracking();  // Wait for stop to finish
              Navigator.of(context).pop(); // Pop the route tracking screen
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  void _pauseTracking() {
    context.read<RouteTrackingCubit>().pauseTracking();
  }

  void _resumeTracking() {
    context.read<RouteTrackingCubit>().resumeTracking();
  }

  void _showRouteDetails(RouteTrack route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteDetailsScreen(route: route),
      ),
    );
  }

  void _deleteRoute(String routeId) {
    final cubit = context.read<RouteTrackingCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: const Text('Are you sure you want to delete this route?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              cubit.deleteRoute(routeId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StartTrackingDialog extends StatefulWidget {
  final Function(String name, String activityType) onStartTracking;

  const _StartTrackingDialog({required this.onStartTracking});

  @override
  State<_StartTrackingDialog> createState() => _StartTrackingDialogState();
}

class _StartTrackingDialogState extends State<_StartTrackingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedActivityType = 'Running';

  final List<String> _activityTypes = [
    'Running',
    'Walking',
    'Cycling',
    'Hiking',
    'Swimming',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start New Route'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 280,
          maxWidth: 400,
          minHeight: 100,
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Route Name',
                    hintText: 'Enter route name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a route name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedActivityType,
                  decoration: const InputDecoration(labelText: 'Activity Type'),
                  items: _activityTypes
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActivityType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onStartTracking(
                _nameController.text.trim(),
                _selectedActivityType,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}
