// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutePoint _$RoutePointFromJson(Map<String, dynamic> json) => RoutePoint(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  speed: (json['speed'] as num?)?.toDouble(),
  altitude: (json['altitude'] as num?)?.toDouble(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
);

Map<String, dynamic> _$RoutePointToJson(RoutePoint instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timestamp': instance.timestamp.toIso8601String(),
      'speed': instance.speed,
      'altitude': instance.altitude,
      'accuracy': instance.accuracy,
    };
