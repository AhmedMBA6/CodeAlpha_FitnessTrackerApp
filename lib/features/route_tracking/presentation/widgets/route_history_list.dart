import 'package:flutter/material.dart';
import '../../data/models/route_track.dart';

class RouteHistoryList extends StatelessWidget {
  final List<RouteTrack> routes;
  final Function(RouteTrack) onRouteTap;
  final Function(String) onRouteDelete;

  const RouteHistoryList({
    super.key,
    required this.routes,
    required this.onRouteTap,
    required this.onRouteDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
      return const SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.route,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No routes yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start tracking to see your routes here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return _RouteHistoryItem(
          route: route,
          onTap: () => onRouteTap(route),
          onDelete: () => onRouteDelete(route.id),
        );
      },
    );
  }
}

class _RouteHistoryItem extends StatelessWidget {
  final RouteTrack route;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RouteHistoryItem({
    required this.route,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getActivityColor(route.activityType),
          child: Icon(
            _getActivityIcon(route.activityType),
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                route.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _buildStatusChip(route),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(route.activityType),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(_formatDistance(route.totalDistance)),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(_formatDuration(route.totalDuration)),
              ],
            ),
            if (route.pausedDuration > Duration.zero) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.pause_circle_filled, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 4),
                  Text('Paused: ${_formatPausedDuration(route.pausedDuration)}'),
                ],
              ),
            ],
            const SizedBox(height: 2),
            Text(
              _formatDate(route.startTime),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getActivityColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return Colors.red;
      case 'walking':
        return Colors.green;
      case 'cycling':
        return Colors.blue;
      case 'hiking':
        return Colors.brown;
      case 'swimming':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'walking':
        return Icons.directions_walk;
      case 'cycling':
        return Icons.directions_bike;
      case 'hiking':
        return Icons.terrain;
      case 'swimming':
        return Icons.pool;
      default:
        return Icons.route;
    }
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

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusChip(RouteTrack route) {
    String label;
    Color color;
    if (route.isActive) {
      if (route.lastPausedTime != null) {
        label = 'Paused';
        color = Colors.amber;
      } else {
        label = 'Active';
        color = Colors.green;
      }
    } else {
      label = 'Completed';
      color = Colors.blueGrey;
    }
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  String _formatPausedDuration(Duration duration) {
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