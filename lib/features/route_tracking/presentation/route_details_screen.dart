import 'package:flutter/material.dart';
import '../data/models/route_track.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteDetailsScreen extends StatelessWidget {
  final RouteTrack route;

  const RouteDetailsScreen({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(route.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (route.points.isNotEmpty)
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(route.points.first.latitude, route.points.first.longitude),
                  zoom: 15,
                ),
                polylines: {
                  Polyline(
                    polylineId: PolylineId('route'),
                    points: route.points
                        .map((p) => LatLng(p.latitude, p.longitude))
                        .toList(),
                    color: Colors.blue,
                    width: 4,
                  ),
                },
                markers: {
                  Marker(
                    markerId: MarkerId('start'),
                    position: LatLng(route.points.first.latitude, route.points.first.longitude),
                    infoWindow: InfoWindow(title: 'Start'),
                  ),
                  if (route.points.length > 1)
                    Marker(
                      markerId: MarkerId('end'),
                      position: LatLng(route.points.last.latitude, route.points.last.longitude),
                      infoWindow: InfoWindow(title: 'End'),
                    ),
                },
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
              ),
            ),
          const SizedBox(height: 16),
          Text('Activity: ${route.activityType}', style: TextStyle(fontSize: 18)),
          Text('Date: ${route.startTime}'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(label: 'Distance', value: '${(route.totalDistance / 1000).toStringAsFixed(2)} km'),
              _StatCard(label: 'Duration', value: _formatDuration(route.totalDuration)),
              _StatCard(label: 'Avg Speed', value: '${route.averageSpeed.toStringAsFixed(2)} m/s'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(label: 'Max Speed', value: '${route.maxSpeed.toStringAsFixed(2)} m/s'),
              _StatCard(label: 'Elevation', value: route.elevationGain != null ? '${route.elevationGain!.toStringAsFixed(1)} m' : '--'),
              _StatCard(label: 'Paused', value: _formatDuration(route.pausedDuration)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
} 