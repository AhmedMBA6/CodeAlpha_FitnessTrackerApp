import 'package:flutter/material.dart';

class TrackingControls extends StatelessWidget {
  final bool isTracking;
  final bool isPaused;
  final bool hasActiveRoute;
  final VoidCallback onStartTracking;
  final VoidCallback onStopTracking;
  final VoidCallback onPauseTracking;
  final VoidCallback onResumeTracking;

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (!hasActiveRoute) ...[
            // Start tracking button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onStartTracking,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else ...[
            // Pause/Resume button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isTracking ? onPauseTracking : onResumeTracking,
                icon: Icon(isTracking ? Icons.pause : Icons.play_arrow),
                label: Text(isTracking ? 'Pause' : 'Resume'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTracking ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Stop tracking button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onStopTracking,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 