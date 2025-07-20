import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class QDatabase {
  static final QDatabase _instance = QDatabase._init();
  static Database? _database;
  bool _isWeb = kIsWeb;

  final sql_questions = '''
        CREATE TABLE IF NOT EXISTS questions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          groupid TEXT NOT NULL,
          instruction TEXT,
          question TEXT,
          answer TEXT,
          image TEXT,
          created TEXT,
          engine TEXT
        );''';
  //--------------------------------------------------------------------------//
  QDatabase._init() {}

  //--------------------------------------------------------------------------//
  factory QDatabase() {
    return _instance;
  }

  //--------------------------------------------------------------------------//
  Future<Database?> init() async {
    // On web, we don't initialize SQLite database
    if (_isWeb) {
      print("Web platform detected - SQLite database disabled");
      return null;
    }
    
    if (_database != null) return _database!;
    _database = await _initDB('offGPT.db');
    _makeFirstRow();
    return _database!;
  }

  //--------------------------------------------------------------------------//
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = "$dbPath/$filePath";
    print("DB Path: $path");

    final options = OpenDatabaseOptions(version: 1, onCreate: _createDB);

    return await databaseFactory.openDatabase(path, options: options);
  }

  //--------------------------------------------------------------------------//
  Future _makeFirstRow() async {
    // On web, skip database operations
    if (_isWeb) {
      print("Web platform - skipping initial database rows");
      return;
    }
    
    final db = await _instance.init();
    if (db == null) return;

    final groupid = const Uuid().v4();
    final questions = await db.rawQuery("SELECT * FROM questions");
    if (questions.length == 0) {
      insertQuestion(groupid, "", tr("l_q1"), tr("l_a1"), null, "ollama");
      insertQuestion(groupid, "", tr("l_q2"), tr("l_a2"), null, "ollama");
      insertQuestion(groupid, "", tr("l_q3"), tr("l_a3"), null, "ollama");
    }
  }

  //--------------------------------------------------------------------------//
  Future _createDB(Database db, int version) async {
    try {
      // Master
      await db.execute(sql_questions);
    } catch (e) {
      print("Error Creating TABLES: $e");
    }
  }

  //--------------------------------------------------------------------------//
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {} catch (e) {
      print("Error Upgrading TABLES: $e");
    }
  }

  //--------------------------------------------------------------------------//
  Future<void> insertQuestion(String groupid, String instruction,
      String question, String answer, String? image, String engine) async {
    // On web, skip database operations
    if (_isWeb) {
      print("Web platform - skipping question insert");
      return;
    }
    
    try {
      String created = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final db = await _instance.init();
      if (db == null) return;
      await db.rawInsert(
          'INSERT INTO questions(groupid, instruction, question, answer, image, created, engine) VALUES(?, ?, ?, ?, ?, ?, ?)',
          [groupid, instruction, question, answer, image, created, engine]);
    } catch (e) {
      print("Error Inserting Master: $e");
    }
  }

  //--------------------------------------------------------------------------//
  Future<List> getTitles() async {
    // On web, return empty list
    if (_isWeb) {
      return [];
    }
    
    final db = await _instance.init();
    if (db == null) return [];
    return await db
        .rawQuery("select * from questions group by groupid order by id desc");
  }

  //--------------------------------------------------------------------------//
  Future<List> getDetails(String groupid) async {
    // On web, return empty list
    if (_isWeb) {
      return [];
    }
    
    final db = await _instance.init();
    if (db == null) return [];
    List details = await db.rawQuery(
        "SELECT * FROM questions WHERE groupid = ? ORDER BY created DESC",
        [groupid]);
    return details;
  }

  //--------------------------------------------------------------------------//
  Future<List> getDetailsById(int id) async {
    // On web, return empty list
    if (_isWeb) {
      return [];
    }
    
    final db = await _instance.init();
    if (db == null) return [];
    List details =
        await db.rawQuery("SELECT * FROM questions WHERE id = ?", [id]);
    return details;
  }

  //--------------------------------------------------------------------------//
  Future<List> searchKeywords(String keyword) async {
    // On web, return empty list
    if (_isWeb) {
      return [];
    }
    
    final db = await _instance.init();
    if (db == null) return [];
    final sql = "SELECT * FROM questions m " +
        "WHERE question LIKE ? OR answer LIKE ? " +
        "ORDER BY created DESC";
    return await db.rawQuery(sql, ["%$keyword%", "%$keyword%"]);
  }

  //--------------------------------------------------------------------------//
  Future<void> deleteQuestions(String groupid) async {
    // On web, skip database operations
    if (_isWeb) {
      print("Web platform - skipping question deletion");
      return;
    }
    
    try {
      final db = await _instance.init();
      if (db == null) return;
      await db.rawDelete('DELETE FROM questions WHERE groupid = ?', [groupid]);
    } catch (e) {
      print("Error Deleting Master: $e");
    }
  }

  //--------------------------------------------------------------------------//
  Future<void> deleteRecord(int id) async {
    // On web, skip database operations
    if (_isWeb) {
      print("Web platform - skipping record deletion");
      return;
    }
    
    try {
      final db = await _instance.init();
      if (db == null) return;
      await db.rawDelete('DELETE FROM questions WHERE id = ?', [id]);
    } catch (e) {
      print("Error Deleting Master: $e");
    }
  }

  //--------------------------------------------------------------------------//
  Future<void> deleteAllRecords() async {
    // On web, skip database operations
    if (_isWeb) {
      print("Web platform - skipping all records deletion");
      return;
    }
    
    try {
      final db = await _instance.init();
      if (db == null) return;
      await db.rawDelete('DELETE FROM questions', []);
    } catch (e) {
      print("Error Deleting Master: $e");
    }
  }
}
