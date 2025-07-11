import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../features/activity_log/data/models/activity_log_model.dart';

class SQLiteHelper {
  static final SQLiteHelper _instance = SQLiteHelper._internal();
  factory SQLiteHelper() => _instance;
  SQLiteHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE activity_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            activityType TEXT NOT NULL,
            duration INTEGER NOT NULL,
            calories REAL NOT NULL,
            date TEXT NOT NULL,
            heartRate INTEGER,
            distance REAL
          )
        ''');
      },
    );
  }

  Future<int> insertActivity(ActivityLogModel log) async {
    final db = await database;
    return await db.insert('activity_logs', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ActivityLogModel>> getAllActivities() async {
    final db = await database;
    final maps = await db.query('activity_logs', orderBy: 'date DESC');
    return maps.map((map) => ActivityLogModel.fromMap(map)).toList();
  }

  Future<int> updateActivity(ActivityLogModel log) async {
    final db = await database;
    return await db.update(
      'activity_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteActivity(int id) async {
    final db = await database;
    return await db.delete('activity_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
} 