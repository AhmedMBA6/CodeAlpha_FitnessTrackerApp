class ActivityLogModel {
  final int? id;
  final String activityType;
  final int duration; // in minutes
  final double calories;
  final DateTime date;
  final int? heartRate; // optional
  final double? distance; // optional (km)

  ActivityLogModel({
    this.id,
    required this.activityType,
    required this.duration,
    required this.calories,
    required this.date,
    this.heartRate,
    this.distance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityType': activityType,
      'duration': duration,
      'calories': calories,
      'date': date.toIso8601String(),
      'heartRate': heartRate,
      'distance': distance,
    };
  }

  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id'] as int?,
      activityType: map['activityType'] as String,
      duration: map['duration'] as int,
      calories: map['calories'] is int ? (map['calories'] as int).toDouble() : map['calories'] as double,
      date: DateTime.parse(map['date'] as String),
      heartRate: map['heartRate'] as int?,
      distance: map['distance'] == null ? null : (map['distance'] is int ? (map['distance'] as int).toDouble() : map['distance'] as double),
    );
  }
} 