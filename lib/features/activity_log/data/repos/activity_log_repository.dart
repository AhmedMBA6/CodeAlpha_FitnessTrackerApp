import '../models/activity_log_model.dart';
import 'activity_log_goal_link_repository.dart';
import 'package:codealpha_fitness_tracker_app/core/utils/sqlite_helper.dart';
import 'dart:convert';

/// Repository for handling activity log data in SQLite.
class ActivityLogRepository {
  final SQLHelper _dbHelper;
  final ActivityLogGoalLinkRepository linkRepo;
  bool _hasFixedNullIds = false; // Flag to prevent re-running the fix

  ActivityLogRepository({SQLHelper? dbHelper, required this.linkRepo}) : _dbHelper = dbHelper ?? SQLHelper();

  Future<List<ActivityLogModel>> getAllActivities({bool runCleanup = false}) async {
    print('[REPO] getAllActivities called');
    
    // Only run cleanup operations if explicitly requested
    if (runCleanup && !_hasFixedNullIds) {
      print('[REPO] About to call fixActivitiesWithNullIds()');
      await fixActivitiesWithNullIds();
      print('[REPO] fixActivitiesWithNullIds() completed');
      _hasFixedNullIds = true;
    } else {
      print('[REPO] Skipping fixActivitiesWithNullIds() - not requested or already fixed');
    }
    
    final maps = await _dbHelper.getAllActivityLogs();
    print('[REPO] Retrieved ${maps.length} activities from database');
    
    final activities = <ActivityLogModel>[];
    
    for (final m in maps) {
      try {
        // Create a new mutable map from the read-only map
        final mutableMap = Map<String, dynamic>.from(m);
        
        // Skip activities with null or empty IDs
        if (mutableMap['id'] == null || mutableMap['id'].toString().isEmpty) {
          print('[REPO] Skipping activity with null/empty ID: ${mutableMap['type']}');
          continue;
        }
        
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
        
        activities.add(ActivityLogModel.fromJson(mutableMap));
      } catch (e) {
        print('[REPO] Error processing activity: $e');
        // Continue with other activities even if one fails
      }
    }
    
    print('[REPO] Returning ${activities.length} ActivityLogModel instances');
    print('[REPO] Activity IDs: ${activities.map((a) => a.id).toList()}');
    return activities;
  }

  Future<String> addActivity(ActivityLogModel log) async {
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
    
    // Insert the data with our generated ID
    await _dbHelper.insertActivityLog(jsonData);
    // Return our generated ID, not the SQLite row ID
    return jsonData['id'];
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

  /// Validates that an activity exists before attempting deletion
  Future<bool> activityExists(String id) async {
    if (id.isEmpty) return false;
    
    try {
      final maps = await _dbHelper.getAllActivityLogs();
      return maps.any((m) => m['id'] == id);
    } catch (e) {
      print('[REPO] Error checking activity existence: $e');
      return false;
    }
  }

  Future<void> deleteActivity(String id, {bool cleanupOrphanedLinks = false}) async {
    print('[DELETE] Starting deletion of activity with ID: $id');
    
    // Validate input
    if (id.isEmpty) {
      throw ArgumentError('Activity ID cannot be empty');
    }
    
    // Check if activity exists before attempting deletion
    final exists = await activityExists(id);
    if (!exists) {
      print('[DELETE] Activity with ID $id does not exist');
      throw Exception('Activity not found. It may have already been deleted.');
    }
    
    try {
      // Debug database state before deletion
      await _dbHelper.debugDatabaseState();
      
      // First, delete all goal links associated with this activity
      final linksBefore = await linkRepo.getLinksForActivityLog(id);
      print('[DELETE] Found ${linksBefore.length} links to delete for activity $id');
      
      if (linksBefore.isNotEmpty) {
        await linkRepo.deleteAllLinksForActivityLog(id);
        
        final linksAfter = await linkRepo.getLinksForActivityLog(id);
        print('[DELETE] Links remaining after deletion: ${linksAfter.length}');
        
        if (linksAfter.isNotEmpty) {
          print('[DELETE] Warning: Some links could not be deleted');
        }
      }
      
      // Then delete the activity log itself
      final deletedRows = await _dbHelper.deleteActivityLog(id);
      print('[DELETE] Deleted $deletedRows rows from activity_logs table');
      
      if (deletedRows == 0) {
        print('[DELETE] Warning: No activity log was deleted. Activity may not exist.');
        // Don't throw error, just log warning
      }
      
      // Only clean up orphaned links if explicitly requested
      if (cleanupOrphanedLinks) {
        await _cleanupOrphanedLinks();
      }
      
      // Debug database state after deletion
      await _dbHelper.debugDatabaseState();
      
      print('[DELETE] Activity deletion completed for ID: $id');
    } catch (e) {
      print('[DELETE] Error during activity deletion: $e');
      print('[DELETE] Stack trace: ${StackTrace.current}');
      throw Exception('Failed to delete activity: ${e.toString()}');
    }
  }

  /// Checks if cleanup operations are needed without running them
  Future<Map<String, dynamic>> checkCleanupNeeded() async {
    print('[CLEANUP] Checking if cleanup operations are needed');
    final result = <String, dynamic>{
      'needsCleanup': false,
      'nullIdActivities': 0,
      'orphanedLinks': 0,
      'duplicateActivities': 0,
    };
    
    try {
      final maps = await _dbHelper.getAllActivityLogs();
      
      // Check for activities with null IDs
      final activitiesWithNullIds = maps.where((m) => m['id'] == null || m['id'].toString().isEmpty).toList();
      result['nullIdActivities'] = activitiesWithNullIds.length;
      
      // Check for orphaned links
      final allLinks = await linkRepo.getAllLinks();
      final allActivities = await getAllActivities();
      final validActivityIds = allActivities.map((a) => a.id).where((id) => id != null).toSet();
      final orphanedLinks = allLinks.where((link) => !validActivityIds.contains(link.activityLogId)).toList();
      result['orphanedLinks'] = orphanedLinks.length;
      
      // Check for duplicate activities
      final Map<String, List<Map<String, dynamic>>> groupedActivities = {};
      for (final activity in maps) {
        final key = '${activity['type']}_${activity['date']}_${activity['duration']}_${activity['calories']}';
        if (!groupedActivities.containsKey(key)) {
          groupedActivities[key] = [];
        }
        groupedActivities[key]!.add(activity);
      }
      
      int duplicateCount = 0;
      for (final activities in groupedActivities.values) {
        if (activities.length > 1) {
          duplicateCount += activities.length - 1;
        }
      }
      result['duplicateActivities'] = duplicateCount;
      
      // Determine if cleanup is needed
      result['needsCleanup'] = result['nullIdActivities'] > 0 || 
                              result['orphanedLinks'] > 0 || 
                              result['duplicateActivities'] > 0;
      
      print('[CLEANUP] Cleanup check completed: $result');
      return result;
    } catch (e) {
      print('[CLEANUP] Error checking cleanup status: $e');
      return result;
    }
  }

  /// Manually triggers cleanup operations (fix null IDs, remove duplicates, clean orphaned links)
  /// This should only be called when explicitly needed, not during normal operations
  Future<void> runCleanupOperations() async {
    print('[CLEANUP] Starting manual cleanup operations');
    try {
      // Fix activities with null IDs
      await fixActivitiesWithNullIds();
      
      // Clean up orphaned links
      await _cleanupOrphanedLinks();
      
      print('[CLEANUP] Manual cleanup operations completed');
    } catch (e) {
      print('[CLEANUP] Error during manual cleanup: $e');
      throw Exception('Failed to run cleanup operations: ${e.toString()}');
    }
  }

  /// Cleans up orphaned links that reference non-existent activities
  Future<void> _cleanupOrphanedLinks() async {
    print('[CLEANUP] Starting orphaned links cleanup');
    try {
      final allLinks = await linkRepo.getAllLinks();
      final allActivities = await getAllActivities();
      final validActivityIds = allActivities.map((a) => a.id).where((id) => id != null).toSet();
      
      int orphanedLinksRemoved = 0;
      for (final link in allLinks) {
        if (!validActivityIds.contains(link.activityLogId)) {
          print('[CLEANUP] Removing orphaned link: ${link.id} for activity: ${link.activityLogId}');
          await linkRepo.deleteLink(link.id);
          orphanedLinksRemoved++;
        }
      }
      
      if (orphanedLinksRemoved > 0) {
        print('[CLEANUP] Removed $orphanedLinksRemoved orphaned links');
      } else {
        print('[CLEANUP] No orphaned links found');
      }
    } catch (e) {
      print('[CLEANUP] Error during orphaned links cleanup: $e');
      // Don't throw error, just log it
    }
  }

  Future<List<ActivityLogModel>> getActivitiesForGoal(String goalId) async {
    final allLogs = await getAllActivities();
    return allLogs.where((log) => log.linkedGoalIds?.contains(goalId) == true).toList();
  }

  /// Fixes activities with null IDs and updates goal links accordingly
  Future<void> fixActivitiesWithNullIds() async {
    print('[REPO] Starting fix for activities with null IDs');
    
    final maps = await _dbHelper.getAllActivityLogs();
    print('[REPO] Total activities in database: ${maps.length}');
    
    final activitiesWithNullIds = maps.where((m) => m['id'] == null || m['id'].toString().isEmpty).toList();
    print('[REPO] Activities with null IDs: ${activitiesWithNullIds.length}');
    
    if (activitiesWithNullIds.isEmpty) {
      print('[REPO] No activities with null IDs found');
      return;
    }
    
    print('[REPO] Found ${activitiesWithNullIds.length} activities with null IDs');
    
    for (final activity in activitiesWithNullIds) {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      print('[REPO] Assigning new ID $newId to activity: ${activity['type']}');
      
      // Create new activity data with the new ID
      final newActivityData = Map<String, dynamic>.from(activity);
      newActivityData['id'] = newId;
      print('[REPO] Creating new activity with data: $newActivityData');
      
      // Delete the old record (with null ID) and insert the new one
      // We need to use a different approach since we can't update by null ID
      await _dbHelper.deleteActivityLogByContent(activity);
      await _dbHelper.insertActivityLog(newActivityData);
      print('[REPO] Activity replaced successfully with new ID: $newId');
      
      // Update any goal links that reference this activity
      // Since the old activity had null ID, we need to find links by other criteria
      final allLinks = await linkRepo.getAllLinks();
      final relevantLinks = allLinks.where((link) => 
        link.activityLogId == '1' || link.activityLogId == activity['id']?.toString()
      ).toList();
      
      print('[REPO] Found ${relevantLinks.length} links to update for old activity');
      for (final link in relevantLinks) {
        final updatedLink = link.copyWith(activityLogId: newId);
        await linkRepo.updateLink(updatedLink.toJson());
        print('[REPO] Updated goal link ${link.id} to use new activity ID: $newId');
      }
    }
    
    // Remove any duplicates that might have been created
    await removeDuplicateActivities();
    
    print('[REPO] Finished fixing activities with null IDs');
  }

  /// Removes duplicate activities (keeps only the first occurrence of each unique activity)
  Future<void> removeDuplicateActivities() async {
    print('[REPO] Starting duplicate removal');
    
    final maps = await _dbHelper.getAllActivityLogs();
    print('[REPO] Total activities before deduplication: ${maps.length}');
    
    // Group activities by their unique characteristics
    final Map<String, List<Map<String, dynamic>>> groupedActivities = {};
    
    for (final activity in maps) {
      final key = '${activity['type']}_${activity['date']}_${activity['duration']}_${activity['calories']}';
      if (!groupedActivities.containsKey(key)) {
        groupedActivities[key] = [];
      }
      groupedActivities[key]!.add(activity);
    }
    
    // Remove duplicates, keeping only the first occurrence
    int duplicatesRemoved = 0;
    for (final entry in groupedActivities.entries) {
      final activities = entry.value;
      if (activities.length > 1) {
        print('[REPO] Found ${activities.length} duplicates for key: ${entry.key}');
        
        // Keep the first one, delete the rest
        for (int i = 1; i < activities.length; i++) {
          final activityToDelete = activities[i];
          print('[REPO] Deleting duplicate activity: ${activityToDelete['id']}');
          await _dbHelper.deleteActivityLog(activityToDelete['id']?.toString() ?? '');
          duplicatesRemoved++;
        }
      }
    }
    
    print('[REPO] Removed $duplicatesRemoved duplicate activities');
    
    final finalMaps = await _dbHelper.getAllActivityLogs();
    print('[REPO] Total activities after deduplication: ${finalMaps.length}');
  }
} 