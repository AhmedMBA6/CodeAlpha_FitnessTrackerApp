import '../models/activity_log_model.dart';
import 'activity_log_goal_link_repository.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/sqlite_helper.dart';
import 'dart:convert';

/// Repository for handling activity log data in SQLite.
class ActivityLogRepository {
  final SQLHelper _dbHelper;
  final ActivityLogGoalLinkRepository linkRepo;

  ActivityLogRepository({SQLHelper? dbHelper, required this.linkRepo}) : _dbHelper = dbHelper ?? SQLHelper();

  Future<List<ActivityLogModel>> getAllActivities() async {
    final maps = await _dbHelper.getAllActivityLogs();
    return maps.map((m) {
      // Create a new mutable map from the read-only map
      final mutableMap = Map<String, dynamic>.from(m);
      // Convert JSON string tags back to List<String> if needed
      if (mutableMap['tags'] is String && mutableMap['tags'].isNotEmpty) {
        try {
          mutableMap['tags'] = jsonDecode(mutableMap['tags']);
        } catch (e) {
          // If JSON decode fails, treat as empty list
          mutableMap['tags'] = <String>[];
        }
      }
      // Map type back to activityType for model compatibility
      if (mutableMap['type'] != null) {
        mutableMap['activityType'] = mutableMap['type'];
        mutableMap.remove('type');
      }
      return ActivityLogModel.fromJson(mutableMap);
    }).toList();
  }

  Future<int> addActivity(ActivityLogModel log) async {
    // Generate a unique ID if not provided
    final jsonData = log.toJson();
    if (jsonData['id'] == null || jsonData['id'].toString().isEmpty) {
      jsonData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    
    // Convert tags list to JSON string for SQLite storage
    if (jsonData['tags'] is List) {
      jsonData['tags'] = jsonEncode(jsonData['tags']);
    }
    // Map activityType to type for database compatibility
    if (jsonData['activityType'] != null) {
      jsonData['type'] = jsonData['activityType'];
      jsonData.remove('activityType');
    }
    await _dbHelper.insertActivityLog(jsonData);
    // Return the generated ID as int
    return int.tryParse(jsonData['id']) ?? DateTime.now().millisecondsSinceEpoch;
  }

  Future<void> updateActivity(ActivityLogModel log) async {
    // Convert tags list to JSON string for SQLite storage
    final jsonData = log.toJson();
    if (jsonData['tags'] is List) {
      jsonData['tags'] = jsonEncode(jsonData['tags']);
    }
    // Map activityType to type for database compatibility
    if (jsonData['activityType'] != null) {
      jsonData['type'] = jsonData['activityType'];
      jsonData.remove('activityType');
    }
    await _dbHelper.updateActivityLog(jsonData);
  }

  Future<void> deleteActivity(String id) async {
    await _dbHelper.deleteActivityLog(id);
  }

  Future<List<ActivityLogModel>> getActivitiesForGoal(String goalId) async {
    final allLogs = await getAllActivities();
    return allLogs.where((log) => log.linkedGoalIds?.contains(goalId) == true).toList();
  }
} 