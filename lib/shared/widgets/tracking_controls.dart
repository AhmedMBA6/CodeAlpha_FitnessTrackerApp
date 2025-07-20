import 'package:flutter/material.dart';

/// Widget for displaying tracking controls (start, pause, resume, stop) for route tracking.
class TrackingControls extends StatelessWidget {
  final bool isTracking;
  final bool isPaused;
  final bool hasActiveRoute;
  final VoidCallback onStartTracking;
  final VoidCallback onStopTracking;
  final VoidCallback onPauseTracking;
  final VoidCallback onResumeTracking;

  /// Creates a [TrackingControls] widget.
  const TrackingControls({
    super.key,
    required this.isTracking,
    required this.isPaused,
    required this.hasActiveRoute,
    required this.onStartTracking,
    required this.onStopTracking,
    required this.onPauseTracking,
    required this.onResumeTracking,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!hasActiveRoute) ...[
          ElevatedButton.icon(
            onPressed: onStartTracking,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ] else ...[
          ElevatedButton.icon(
            onPressed: isTracking ? onPauseTracking : onResumeTracking,
            icon: Icon(isTracking ? Icons.pause : Icons.play_arrow),
            label: Text(isTracking ? 'Pause' : 'Resume'),
            style: ElevatedButton.styleFrom(backgroundColor: isTracking ? Colors.orange : Colors.green, foregroundColor: Colors.white),
          ),
          ElevatedButton.icon(
            onPressed: onStopTracking,
            icon: const Icon(Icons.stop),
            label: const Text('Stop'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ],
      ],
    );
  }
} 