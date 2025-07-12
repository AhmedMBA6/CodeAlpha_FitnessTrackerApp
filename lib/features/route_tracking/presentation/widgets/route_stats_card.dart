import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/route_track.dart';
import '../../data/models/route_point.dart';
import 'dart:async';

class RouteStatsCard extends StatefulWidget {
  final RouteTrack route;

  const RouteStatsCard({
    super.key,
    required this.route,
  });

  @override
  State<RouteStatsCard> createState() => _RouteStatsCardState();
}

class _RouteStatsCardState extends State<RouteStatsCard> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentDistance = widget.route.currentDistance;
    final currentDuration = widget.route.currentDuration;
    final currentSpeed = _calculateCurrentSpeed();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.route.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Distance',
                  _formatDistance(currentDistance),
                  Icons.straighten,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Duration',
                  _formatDuration(currentDuration),
                  Icons.timer,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Speed',
                  _formatSpeed(currentSpeed),
                  Icons.speed,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  double _calculateCurrentSpeed() {
    if (widget.route.points.length < 2) return 0.0;
    
    final recentPoints = widget.route.points.length > 5 
        ? widget.route.points.sublist(widget.route.points.length - 5)
        : widget.route.points;
    if (recentPoints.length < 2) return 0.0;

    double totalDistance = 0.0;
    Duration totalTime = Duration.zero;

    for (int i = 1; i < recentPoints.length; i++) {
      totalDistance += _calculateDistance(recentPoints[i - 1], recentPoints[i]);
      totalTime += recentPoints[i].timestamp.difference(recentPoints[i - 1].timestamp);
    }

    if (totalTime.inSeconds == 0) return 0.0;
    return totalDistance / totalTime.inSeconds;
  }

  double _calculateDistance(RoutePoint point1, RoutePoint point2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final lat1Rad = point1.latitude * (3.14159265359 / 180);
    final lat2Rad = point2.latitude * (3.14159265359 / 180);
    final deltaLatRad = (point2.latitude - point1.latitude) * (3.14159265359 / 180);
    final deltaLonRad = (point2.longitude - point1.longitude) * (3.14159265359 / 180);

    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    final c = 2 * atan(sqrt(a) / sqrt(1 - a));

    return earthRadius * c;
  }

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(2)}km';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String _formatSpeed(double speedInMps) {
    if (speedInMps < 1) {
      return '${(speedInMps * 100).toStringAsFixed(0)}cm/s';
    } else if (speedInMps < 1000) {
      return '${speedInMps.toStringAsFixed(1)}m/s';
    } else {
      return '${(speedInMps / 1000).toStringAsFixed(1)}km/s';
    }
  }
} 