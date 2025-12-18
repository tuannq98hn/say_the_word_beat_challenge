import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/challenge.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'custom_challenges.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE custom_challenges (
            id TEXT PRIMARY KEY,
            challenge_json TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveChallenge(Challenge challenge) async {
    final db = await database;
    final jsonString = jsonEncode(challenge.toJson());
    await db.insert(
      'custom_challenges',
      {
        'id': challenge.id,
        'challenge_json': jsonString,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Challenge>> loadChallenges() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'custom_challenges',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) {
      final jsonString = map['challenge_json'] as String;
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Challenge.fromJson(json);
    }).toList();
  }

  Future<void> deleteChallenge(String id) async {
    final db = await database;
    await db.delete(
      'custom_challenges',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
