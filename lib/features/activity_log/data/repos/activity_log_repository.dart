import '../../../../core/utils/sqlite_helper.dart';
import '../models/activity_log_model.dart';

class ActivityLogRepository {
  final SQLiteHelper _dbHelper = SQLiteHelper();

  Future<int> addActivity(ActivityLogModel log) async {
    return await _dbHelper.insertActivity(log);
  }

  Future<List<ActivityLogModel>> getAllActivities() async {
    return await _dbHelper.getAllActivities();
  }

  Future<int> updateActivity(ActivityLogModel log) async {
    return await _dbHelper.updateActivity(log);
  }

  Future<int> deleteActivity(int id) async {
    return await _dbHelper.deleteActivity(id);
  }
} 