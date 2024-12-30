import 'package:flutter_notes_app/models/planner.dart';
import 'package:flutter_notes_app/models/user.dart';
import 'package:flutter_notes_app/models/habit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  //Khoiwoiwr tạo Database
  // version de quan ly phien ban DB
  // onCreate sẽ ược khi database được tạo lần dau
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), "notes.db");
    // print('Database Path: $path');
    await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 1, // Tăng phiên bản từ 1 lên 2
      onCreate: _createDB,
      // onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES user (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE planners(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        targetDays INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT,
        isCompleted INTEGER NOT NULL CHECK (isCompleted IN (0, 1)),
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_completed_dates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        completedDate TEXT NOT NULL,
        FOREIGN KEY (habitId) REFERENCES habits (id)
      )
    ''');
  }

  //================
  /*USER OPERATIONS */
  //================

  // User operations
  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return user..id = id;
  }

  Future<User?> getUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  //================
  /*NOTE OPERATIONS */
  //================
  // Note operations
  Future<Note> createNote(Note note) async {
    final db = await instance.database;
    final id = await db.insert('notes', note.toMap());
    return note..id = id;
  }

  Future<List<Note>> getNotes(int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'notes',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //================
  /*PLANNER OPERATIONS */
  //================

  // Thêm các phương thức cho Planner
  Future<Planner> createPlanner(Planner planner) async {
    final db = await instance.database;
    final id = await db.insert('planners', planner.toMap());
    return planner..id = id;
  }

  Future<List<Planner>> getPlanners(int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'planners',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Planner.fromMap(map)).toList();
  }

  Future<int> updatePlanner(Planner planner) async {
    final db = await instance.database;
    return db.update(
      'planners',
      planner.toMap(),
      where: 'id = ?',
      whereArgs: [planner.id],
    );
  }

  Future<int> deletePlanner(int id) async {
    final db = await instance.database;
    return await db.delete(
      'planners',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //================
  /*HABIT OPERATIONS */
  //================
  Future<Habit> createHabit(Habit habit) async {
    final db = await instance.database;
    final id = await db.insert('habits', habit.toMap());
    return habit..id = id;
  }

  Future<List<Habit>> getHabits(int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'habits',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'startDate DESC',
    );
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await instance.database;
    return db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await instance.database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markHabitCompleted( int habitId) async {
    final today = DateTime.now();
    Database db = await instance.database;
    final formattedDate = today.toIso8601String();

    // Kiểm tra nếu ngày đã được đánh dấu
    final existingRecord = await db.query(
      'habit_completed_dates',
      where: 'habitId = ? AND completedDate = ?',
      whereArgs: [habitId, formattedDate],
    );

    if (existingRecord.isEmpty) {
      // Chỉ thêm nếu ngày chưa được đánh dấu
      await db.insert('habit_completed_dates', {
        'habitId': habitId,
        'completedDate': formattedDate,
      });
    }
  }

  Future<int> calculateCurrentStreak(int habitId) async {
    Database db = await instance.database;
    // Lấy danh sách ngày hoàn thành của habit, sắp xếp theo thứ tự giảm dần
    final List<Map<String, dynamic>> completedDates = await db.query(
      'habit_completed_dates',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'completedDate DESC',
    );

    if (completedDates.isEmpty) {
      return 0; // Không có ngày hoàn thành, chuỗi = 0
    }

    int streak = 0;
    DateTime? previousDate;

    for (final record in completedDates) {
      DateTime currentDate = DateTime.parse(record['completedDate']);

      if (previousDate == null || 
          previousDate.difference(currentDate).inDays == 1) {
        // Ngày liên tiếp
        streak++;
      } else if (previousDate.difference(currentDate).inDays > 1) {
        // Chuỗi bị ngắt
        break;
      }

      previousDate = currentDate;
    }

    return streak;
  }

  

}
