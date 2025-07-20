import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static final SQLHelper _instance = SQLHelper._internal();
  factory SQLHelper() => _instance;
  SQLHelper._internal();

  static Database? _db;

  /// Reset the database (for testing purposes)
  static Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'activity_tracker.db');
    print('[DB RESET] Deleting database at: $path');
    await deleteDatabase(path);
    _db = null;
    print('[DB RESET] Database deleted and will be recreated on next access');
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'activity_tracker.db');

    print('[DB DEBUG] Database path: $path');
    print('[DB DEBUG] Attempting to open database with version 5');

    return await openDatabase(
      path,
      version: 6, // Incremented version for activity_logs missing columns
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    print('[DB CREATE] Creating database with version $version');
    await db.execute('''
      CREATE TABLE activity_logs (
        id TEXT PRIMARY KEY,
        type TEXT,
        duration INTEGER,
        calories INTEGER,
        notes TEXT,
        startTime TEXT,
        endTime TEXT,
        date TEXT,
        goalId TEXT,
        tags TEXT,
        heartRate INTEGER,
        distance REAL
      );
    ''');

    await db.execute('''
      CREATE TABLE activity_goals (
        id TEXT PRIMARY KEY,
        goalType TEXT,
        description TEXT,
        targetValue REAL,
        unit TEXT,
        tags TEXT,
        createdAt TEXT,
        progress REAL,
        isCompleted INTEGER,
        isArchived INTEGER,
        title TEXT,
        targetDuration INTEGER,
        targetCalories INTEGER,
        startDate TEXT,
        endDate TEXT,
        status TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE activity_log_goal_link (
        id TEXT PRIMARY KEY,
        activityLogId TEXT,
        goalId TEXT,
        contributedValue REAL,
        contributionType TEXT,
        linkedAt TEXT,
        unlinkedAt TEXT
      );
    ''');
    print('[DB CREATE] Database tables created successfully');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('[DB MIGRATION] Upgrading database from version $oldVersion to $newVersion');
    try {
      await db.execute('ALTER TABLE activity_logs ADD COLUMN goalId TEXT;');
    } catch (e) {
      if (!e.toString().contains('duplicate') && !e.toString().contains('no such table')) {
        rethrow;
      }
    }
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS activity_log_goal_link (
          id TEXT PRIMARY KEY,
          activityLogId TEXT,
          goalId TEXT,
          contributedValue REAL,
          contributionType TEXT,
          linkedAt TEXT,
          unlinkedAt TEXT
        );
      ''');
    } catch (e) {
      if (!e.toString().contains('duplicate') && !e.toString().contains('no such table')) {
        rethrow;
      }
    }
    // Migration: Add goalType column to activity_goals if it doesn't exist
    if (oldVersion < 3) {
      print('[DB MIGRATION] Adding goalType column (oldVersion: $oldVersion)');
      try {
        await db.execute('ALTER TABLE activity_goals ADD COLUMN goalType TEXT;');
        print('[DB MIGRATION] goalType column added successfully');
      } catch (e) {
        print('[DB MIGRATION] Error adding goalType column: $e');
        if (!e.toString().contains('duplicate') && !e.toString().contains('no such table')) {
          rethrow;
        }
      }
    }
    // Migration: Add targetValue column to activity_goals if it doesn't exist
    if (oldVersion < 4) {
      print('[DB MIGRATION] Attempting to add targetValue column to activity_goals...');
      try {
        await db.execute('ALTER TABLE activity_goals ADD COLUMN targetValue REAL;');
        print('[DB MIGRATION] targetValue column added successfully.');
      } catch (e) {
        print('[DB MIGRATION] Error adding targetValue column: $e');
        if (!e.toString().contains('duplicate') && !e.toString().contains('no such table')) {
          rethrow;
        }
      }
    }
    // Migration: Add all missing columns to activity_goals if they don't exist
    if (oldVersion < 6) {
      print('[DB MIGRATION] Attempting to add all missing columns to activity_goals...');
      try { await db.execute('ALTER TABLE activity_goals ADD COLUMN unit TEXT;'); print('[DB MIGRATION] unit column added.'); } catch (e) { print('[DB MIGRATION] unit: $e'); }
      try { await db.execute('ALTER TABLE activity_goals ADD COLUMN tags TEXT;'); print('[DB MIGRATION] tags column added.'); } catch (e) { print('[DB MIGRATION] tags: $e'); }
      try { await db.execute('ALTER TABLE activity_goals ADD COLUMN createdAt TEXT;'); print('[DB MIGRATION] createdAt column added.'); } catch (e) { print('[DB MIGRATION] createdAt: $e'); }
      try { await db.execute('ALTER TABLE activity_goals ADD COLUMN progress REAL;'); print('[DB MIGRATION] progress column added.'); } catch (e) { print('[DB MIGRATION] progress: $e'); }
      try { await db.execute('ALTER TABLE activity_goals ADD COLUMN isCompleted INTEGER;'); print('[DB MIGRATION] isCompleted column added.'); } catch (e) { print('[DB MIGRATION] isCompleted: $e'); }
      try { await db.execute('ALTER TABLE activity_goals ADD COLUMN isArchived INTEGER;'); print('[DB MIGRATION] isArchived column added.'); } catch (e) { print('[DB MIGRATION] isArchived: $e'); }
      // Migration: Add missing columns to activity_logs
      try { await db.execute('ALTER TABLE activity_logs ADD COLUMN heartRate INTEGER;'); print('[DB MIGRATION] heartRate column added to activity_logs.'); } catch (e) { print('[DB MIGRATION] heartRate: $e'); }
      try { await db.execute('ALTER TABLE activity_logs ADD COLUMN distance REAL;'); print('[DB MIGRATION] distance column added to activity_logs.'); } catch (e) { print('[DB MIGRATION] distance: $e'); }
    }
    print('[DB MIGRATION] Database upgrade completed');
  }

  // -------------------- ACTIVITY LOG METHODS --------------------
  Future<void> insertActivityLog(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('activity_logs', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllActivityLogs() async {
    final db = await database;
    return await db.query('activity_logs', orderBy: 'startTime DESC');
  }

  Future<int> deleteActivityLog(String id) async {
    final db = await database;
    return await db.delete('activity_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateActivityLog(Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('activity_logs', data, where: 'id = ?', whereArgs: [data['id']]);
  }

  // -------------------- ACTIVITY GOALS METHODS --------------------
  Future<void> insertActivityGoal(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('activity_goals', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllActivityGoals() async {
    final db = await database;
    return await db.query('activity_goals', orderBy: 'startDate DESC');
  }

  Future<int> deleteActivityGoal(String id) async {
    final db = await database;
    return await db.delete('activity_goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateActivityGoal(Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('activity_goals', data, where: 'id = ?', whereArgs: [data['id']]);
  }

  // -------------------- ACTIVITY LOG GOAL LINK METHODS --------------------
  Future<void> insertLink(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('activity_log_goal_link', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getLinksForActivityLog(String logId) async {
    final db = await database;
    return await db.query('activity_log_goal_link', where: 'activityLogId = ?', whereArgs: [logId]);
  }

  Future<List<Map<String, dynamic>>> getLinksForGoal(String goalId) async {
    final db = await database;
    return await db.query('activity_log_goal_link', where: 'goalId = ?', whereArgs: [goalId]);
  }

  Future<List<Map<String, dynamic>>> getAllLinks() async {
    final db = await database;
    return await db.query('activity_log_goal_link');
  }

  Future<int> deleteLink(String id) async {
    final db = await database;
    return await db.delete('activity_log_goal_link', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateLink(Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('activity_log_goal_link', data, where: 'id = ?', whereArgs: [data['id']]);
  }

  // -------------------- DASHBOARD HELPERS --------------------
  Future<int> countTotalActivityLogs() async {
    final db = await database;
    final result = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM activity_logs'));
    return result ?? 0;
  }

  Future<int> totalDuration() async {
    final db = await database;
    final result = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(duration) FROM activity_logs'));
    return result ?? 0;
  }

  Future<List<Map<String, dynamic>>> fetchLogsByDateRange(String from, String to) async {
    final db = await database;
    return await db.query(
      'activity_logs',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [from, to],
      orderBy: 'startTime DESC',
    );
  }

  Future<List<Map<String, dynamic>>> fetchLogsByGoalId(String goalId) async {
    final db = await database;
    return await db.query(
      'activity_logs',
      where: 'goalId = ?',
      whereArgs: [goalId],
    );
  }

  Future<List<Map<String, dynamic>>> getGoalsByArchived(bool isArchived) async {
    final db = await database;
    return await db.query('activity_goals', where: 'isArchived = ?', whereArgs: [isArchived ? 1 : 0]);
  }
} 