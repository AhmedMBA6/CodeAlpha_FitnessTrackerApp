import 'package:json_annotation/json_annotation.dart';

part 'route_point.g.dart';

@JsonSerializable()
class RoutePoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed; // in meters per second
  final double? altitude; // in meters
  final double? accuracy; // GPS accuracy in meters

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed,
    this.altitude,
    this.accuracy,
  });

  factory RoutePoint.fromJson(Map<String, dynamic> json) =>
      _$RoutePointFromJson(json);

  Map<String, dynamic> toJson() => _$RoutePointToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'speed': speed,
      'altitude': altitude,
      'accuracy': accuracy,
    };
  }

  factory RoutePoint.fromMap(Map<String, dynamic> map) {
    return RoutePoint(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      timestamp: DateTime.parse(map['timestamp'] as String),
      speed: map['speed'] as double?,
      altitude: map['altitude'] as double?,
      accuracy: map['accuracy'] as double?,
    );
  }

  RoutePoint copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? speed,
    double? altitude,
    double? accuracy,
  }) {
    return RoutePoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      speed: speed ?? this.speed,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  String toString() {
    return 'RoutePoint(latitude: $latitude, longitude: $longitude, timestamp: $timestamp, speed: $speed, altitude: $altitude, accuracy: $accuracy)';
  }
} 