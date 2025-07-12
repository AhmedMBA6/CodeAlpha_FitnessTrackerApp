import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../features/activity_log/data/models/activity_log_model.dart';
import '../../../features/route_tracking/data/models/route_track.dart';
import '../../../features/route_tracking/data/models/route_point.dart';

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
      version: 4, // Bump version to add goal support
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
        
        await db.execute('''
          CREATE TABLE routes (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            start_time TEXT NOT NULL,
            end_time TEXT,
            total_distance REAL NOT NULL,
            total_duration INTEGER NOT NULL,
            average_speed REAL NOT NULL,
            max_speed REAL NOT NULL,
            elevation_gain REAL,
            activity_type TEXT NOT NULL,
            paused_duration INTEGER,
            last_paused_time TEXT,
            goal_type TEXT,
            goal_distance REAL,
            goal_destination_lat REAL,
            goal_destination_lng REAL,
            goal_destination_timestamp TEXT,
            goal_description TEXT,
            goal_created_at TEXT
          )
        ''');
        
        await db.execute('''
          CREATE TABLE route_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            route_id TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            speed REAL,
            altitude REAL,
            accuracy REAL,
            FOREIGN KEY (route_id) REFERENCES routes (id) ON DELETE CASCADE
          )
        ''');
        
        await db.execute('''
          CREATE TABLE active_routes (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            start_time TEXT NOT NULL,
            end_time TEXT,
            total_distance REAL NOT NULL,
            total_duration INTEGER NOT NULL,
            average_speed REAL NOT NULL,
            max_speed REAL NOT NULL,
            elevation_gain REAL,
            activity_type TEXT NOT NULL,
            paused_duration INTEGER,
            last_paused_time TEXT,
            goal_type TEXT,
            goal_distance REAL,
            goal_destination_lat REAL,
            goal_destination_lng REAL,
            goal_destination_timestamp TEXT,
            goal_description TEXT,
            goal_created_at TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add end_time column to active_routes if it doesn't exist
          try {
            await db.execute('ALTER TABLE active_routes ADD COLUMN end_time TEXT;');
          } catch (e) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        // Add paused_duration and last_paused_time columns to routes and active_routes if missing
        try {
          await db.execute('ALTER TABLE routes ADD COLUMN paused_duration INTEGER;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE routes ADD COLUMN last_paused_time TEXT;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE active_routes ADD COLUMN paused_duration INTEGER;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE active_routes ADD COLUMN last_paused_time TEXT;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        
        // Add goal columns to routes table
        try {
          await db.execute('ALTER TABLE routes ADD COLUMN goal_type TEXT;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE routes ADD COLUMN goal_distance REAL;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE routes ADD COLUMN goal_destination_lat REAL;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE routes ADD COLUMN goal_destination_lng REAL;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE routes ADD COLUMN goal_destination_timestamp TEXT;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE routes ADD COLUMN goal_description TEXT;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE routes ADD COLUMN goal_created_at TEXT;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        
        // Add goal columns to active_routes table
        try {
          await db.execute('ALTER TABLE active_routes ADD COLUMN goal_type TEXT;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE active_routes ADD COLUMN goal_distance REAL;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE active_routes ADD COLUMN goal_destination_lat REAL;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE active_routes ADD COLUMN goal_destination_lng REAL;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE active_routes ADD COLUMN goal_destination_timestamp TEXT;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE active_routes ADD COLUMN goal_description TEXT;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
        try {
          await db.execute('ALTER TABLE active_routes ADD COLUMN goal_created_at TEXT;');
        } catch (e) {
          if (!e.toString().contains('duplicate column')) {
            if (!e.toString().contains('no such table')) {
              rethrow;
            }
          }
        }
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

  // Route Tracking Methods
  Future<int> insertRoute(RouteTrack route) async {
    final db = await database;
    return await db.insert('routes', route.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<RouteTrack>> getAllRoutes() async {
    final db = await database;
    final routeMaps = await db.query('routes', orderBy: 'start_time DESC');
    final routes = <RouteTrack>[];
    
    for (final routeMap in routeMaps) {
      final routeId = routeMap['id'] as String;
      final points = await getRoutePoints(routeId);
      routes.add(RouteTrack.fromMap(routeMap, points));
    }
    
    return routes;
  }

  Future<RouteTrack?> getRouteById(String routeId) async {
    final db = await database;
    final routeMaps = await db.query('routes', where: 'id = ?', whereArgs: [routeId]);
    
    if (routeMaps.isEmpty) return null;
    
    final points = await getRoutePoints(routeId);
    return RouteTrack.fromMap(routeMaps.first, points);
  }

  Future<int> updateRoute(RouteTrack route) async {
    final db = await database;
    return await db.update(
      'routes',
      route.toMap(),
      where: 'id = ?',
      whereArgs: [route.id],
    );
  }

  Future<int> deleteRoute(String routeId) async {
    final db = await database;
    // Delete route points first (cascade will handle this, but explicit for clarity)
    await db.delete('route_points', where: 'route_id = ?', whereArgs: [routeId]);
    return await db.delete('routes', where: 'id = ?', whereArgs: [routeId]);
  }

  Future<void> insertRoutePoints(String routeId, List<RoutePoint> points) async {
    final db = await database;
    final batch = db.batch();
    
    for (final point in points) {
      batch.insert('route_points', {
        'route_id': routeId,
        'latitude': point.latitude,
        'longitude': point.longitude,
        'timestamp': point.timestamp.toIso8601String(),
        'speed': point.speed,
        'altitude': point.altitude,
        'accuracy': point.accuracy,
      });
    }
    
    await batch.commit(noResult: true);
  }

  Future<List<RoutePoint>> getRoutePoints(String routeId) async {
    final db = await database;
    final pointMaps = await db.query(
      'route_points',
      where: 'route_id = ?',
      whereArgs: [routeId],
      orderBy: 'timestamp ASC',
    );
    
    return pointMaps.map((map) => RoutePoint.fromMap(map)).toList();
  }

  Future<void> updateRoutePoints(String routeId, List<RoutePoint> points) async {
    final db = await database;
    // Delete existing points and insert new ones
    await db.delete('route_points', where: 'route_id = ?', whereArgs: [routeId]);
    await insertRoutePoints(routeId, points);
  }

  // Active Route Methods
  Future<void> saveActiveRoute(RouteTrack? route) async {
    final db = await database;
    
    if (route == null) {
      await db.delete('active_routes');
    } else {
      await db.insert('active_routes', route.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      if (route.points.isNotEmpty) {
        await updateRoutePoints(route.id, route.points);
      }
    }
  }

  Future<RouteTrack?> getActiveRoute() async {
    final db = await database;
    final routeMaps = await db.query('active_routes');
    
    if (routeMaps.isEmpty) return null;
    
    final routeId = routeMaps.first['id'] as String;
    final points = await getRoutePoints(routeId);
    return RouteTrack.fromMap(routeMaps.first, points);
  }

  Future<List<RouteTrack>> getRoutesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final routeMaps = await db.query(
      'routes',
      where: 'start_time BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'start_time DESC',
    );
    
    final routes = <RouteTrack>[];
    for (final routeMap in routeMaps) {
      final routeId = routeMap['id'] as String;
      final points = await getRoutePoints(routeId);
      routes.add(RouteTrack.fromMap(routeMap, points));
    }
    
    return routes;
  }

  Future<List<RouteTrack>> getRoutesByActivityType(String activityType) async {
    final db = await database;
    final routeMaps = await db.query(
      'routes',
      where: 'activity_type = ?',
      whereArgs: [activityType],
      orderBy: 'start_time DESC',
    );
    
    final routes = <RouteTrack>[];
    for (final routeMap in routeMaps) {
      final routeId = routeMap['id'] as String;
      final points = await getRoutePoints(routeId);
      routes.add(RouteTrack.fromMap(routeMap, points));
    }
    
    return routes;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
} 