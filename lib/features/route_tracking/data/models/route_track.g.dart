// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteTrack _$RouteTrackFromJson(Map<String, dynamic> json) => RouteTrack(
  id: json['id'] as String,
  name: json['name'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  points: (json['points'] as List<dynamic>)
      .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalDistance: (json['totalDistance'] as num).toDouble(),
  totalDuration: Duration(microseconds: (json['totalDuration'] as num).toInt()),
  averageSpeed: (json['averageSpeed'] as num).toDouble(),
  maxSpeed: (json['maxSpeed'] as num).toDouble(),
  elevationGain: (json['elevationGain'] as num?)?.toDouble(),
  activityType: json['activityType'] as String,
  pausedDuration: json['pausedDuration'] == null
      ? Duration.zero
      : Duration(microseconds: (json['pausedDuration'] as num).toInt()),
  lastPausedTime: json['lastPausedTime'] == null
      ? null
      : DateTime.parse(json['lastPausedTime'] as String),
  goal: json['goal'] == null
      ? null
      : ActivityGoal.fromJson(json['goal'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RouteTrackToJson(RouteTrack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'points': instance.points,
      'totalDistance': instance.totalDistance,
      'totalDuration': instance.totalDuration.inMicroseconds,
      'averageSpeed': instance.averageSpeed,
      'maxSpeed': instance.maxSpeed,
      'elevationGain': instance.elevationGain,
      'activityType': instance.activityType,
      'pausedDuration': instance.pausedDuration.inMicroseconds,
      'lastPausedTime': instance.lastPausedTime?.toIso8601String(),
      'goal': instance.goal,
    };
