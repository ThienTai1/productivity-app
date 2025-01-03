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
    // await deleteDatabase(path);
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
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
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
        completedDates TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_completed_dates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        completedDate TEXT NOT NULL,
        FOREIGN KEY (habitId) REFERENCES habits (id) ON DELETE CASCADE
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
  Future<int> calculateCurrentStreak(int habitId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> completedDates = await db.query(
      'habit_completed_dates',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'completedDate DESC',
    );

    if (completedDates.isEmpty) return 0;

    int streak = 1; // Bắt đầu với 1 vì có ít nhất 1 ngày hoàn thành
    DateTime currentDate = DateTime.now();

    // Sắp xếp các ngày theo thứ tự giảm dần
    List<DateTime> dates = completedDates
        .map((record) => DateTime.parse(record['completedDate'] as String))
        .toList()
      ..sort((a, b) => b.compareTo(a));

    // Kiểm tra ngày gần nhất có phải là hôm nay hoặc hôm qua
    if (dates.first.difference(currentDate).inDays.abs() > 1) {
      return 0; // Chuỗi đã bị đứt
    }

    // Đếm số ngày liên tiếp
    for (int i = 0; i < dates.length - 1; i++) {
      if (dates[i].difference(dates[i + 1]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<int> calculateLongestStreak(int habitId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> completedDates = await db.query(
      'habit_completed_dates',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'completedDate ASC',
    );

    if (completedDates.isEmpty) return 0;

    int longestStreak = 1;
    int currentStreak = 1;

    List<DateTime> dates = completedDates
        .map((record) => DateTime.parse(record['completedDate'] as String))
        .toList();

    // Tính streak dài nhất
    for (int i = 0; i < dates.length - 1; i++) {
      if (dates[i + 1].difference(dates[i]).inDays == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  Future<int> createHabit(Habit habit) async {
    final db = await database;
    final id = await db.insert('habits', habit.toMap());
    if (habit.completedDates.isNotEmpty) {
      final batch = db.batch();
      for (var date in habit.completedDates) {
        batch.insert('habit_completed_dates', {
          'habitId': id,
          'completedDate': date.toIso8601String(),
        });
      }
      await batch.commit();
    }
    return id;
  }

  Future<List<Habit>> getHabits(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> habitMaps = await db.query(
      'habits',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    // Fetch completed dates for each habit
    return Future.wait(habitMaps.map((habitMap) async {
      final List<Map<String, dynamic>> datesMaps = await db.query(
        'habit_completed_dates',
        columns: ['completedDate'],
        where: 'habitId = ?',
        whereArgs: [habitMap['id']],
      );

      final List<DateTime> completedDates = datesMaps
          .map((dateMap) => DateTime.parse(dateMap['completedDate'] as String))
          .toList();

      return Habit.fromMap(habitMap, completedDates);
    }));
  }

  Future<Habit?> getHabit(int habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [habitId],
    );

    if (maps.isEmpty) return null;

    final List<Map<String, dynamic>> datesMaps = await db.query(
      'habit_completed_dates',
      columns: ['completedDate'],
      where: 'habitId = ?',
      whereArgs: [habitId],
    );

    final List<DateTime> completedDates = datesMaps
        .map((dateMap) => DateTime.parse(dateMap['completedDate'] as String))
        .toList();

    return Habit.fromMap(maps.first, completedDates);
  }

  Future<void> updateHabit(Habit habit) async {
    final db = await database;
    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );

    // Update completed dates
    await db.delete(
      'habit_completed_dates',
      where: 'habitId = ?',
      whereArgs: [habit.id],
    );

    if (habit.completedDates.isNotEmpty) {
      final batch = db.batch();
      for (var date in habit.completedDates) {
        batch.insert('habit_completed_dates', {
          'habitId': habit.id,
          'completedDate': date.toIso8601String(),
        });
      }
      await batch.commit();
    }
  }

  Future<void> deleteHabit(int habitId) async {
    final db = await database;
    await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [habitId],
    );
    // Completed dates will be automatically deleted due to CASCADE
  }

Future<void> markHabitAsCompleted(int habitId, DateTime date) async {
  final db = await database;

  // Chỉ lấy ngày, tháng, năm
  final truncatedDate = DateTime(date.year, date.month, date.day);

  // Lưu vào bảng habit_completed_dates
  await db.insert('habit_completed_dates', {
    'habitId': habitId,
    'completedDate': truncatedDate.toIso8601String().split('T').first,
  });

  final habit = await getHabit(habitId);

  if (habit != null) {
    // Cập nhật completedDates trong bảng habits
    final allCompletedDates = [
      ...habit.completedDates.map((date) => date.toIso8601String().split('T').first),
      truncatedDate.toIso8601String().split('T').first
    ];

    await db.update(
      'habits',
      {'completedDates': allCompletedDates.join(',')},
      where: 'id = ?',
      whereArgs: [habitId],
    );

    // Kiểm tra nếu đủ targetDays, đánh dấu là hoàn thành
    if (allCompletedDates.length >= habit.targetDays) {
      print('Marking habit as completed');
      await db.update(
        'habits',
        {'isCompleted': 1},
        where: 'id = ?',
        whereArgs: [habitId],
      );
    }
  }
}


Future<void> unmarkHabitAsCompleted(int habitId, DateTime date) async {
  final db = await database;

  // Chỉ lấy ngày, tháng, năm
  final truncatedDate = DateTime(date.year, date.month, date.day);
  final dateString = truncatedDate.toIso8601String().split('T').first;

  // Xóa khỏi bảng habit_completed_dates
  await db.delete(
    'habit_completed_dates',
    where: 'habitId = ? AND completedDate = ?',
    whereArgs: [habitId, dateString],
  );

  final habit = await getHabit(habitId);

  if (habit != null) {
    // Cập nhật completedDates trong bảng habits bằng cách loại bỏ ngày đã chọn
    final updatedCompletedDates = habit.completedDates
        .map((date) => date.toIso8601String().split('T').first)
        .where((d) => d != dateString)
        .toList();

    await db.update(
      'habits',
      {'completedDates': updatedCompletedDates.join(',')},
      where: 'id = ?',
      whereArgs: [habitId],
    );

    // Kiểm tra nếu số ngày hoàn thành < targetDays, đánh dấu là chưa hoàn thành
    if (updatedCompletedDates.length < habit.targetDays) {
      print('Marking habit as incomplete');
      await db.update(
        'habits',
        {'isCompleted': 0},
        where: 'id = ?',
        whereArgs: [habitId], 
      );
    }
  }
}

  Future<List<DateTime>> getCompletedDates(int habitId) async {
  final db = await database;

  // Truy vấn bảng habit_completed_dates dựa trên habitId
  final List<Map<String, dynamic>> result = await db.query(
    'habit_completed_dates',
    columns: ['completedDate'], // Chỉ lấy cột completedDate
    where: 'habitId = ?',
    whereArgs: [habitId],
  );

  // Chuyển đổi kết quả thành List<DateTime>
  final completedDates = result.map((row) {
    return DateTime.parse(row['completedDate'] as String); // Chuyển thành DateTime
  }).toList();

  return completedDates; // Trả về danh sách
}

}
