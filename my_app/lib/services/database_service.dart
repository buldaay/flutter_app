import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../models/media_category.dart';
import '../models/media_item.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<void> init() async {
    if (_database != null) {
      return;
    }

    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath${Platform.pathSeparator}tv_media_library.db';

    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        folderPath TEXT NOT NULL UNIQUE,
        bannerPath TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        videoPath TEXT NOT NULL UNIQUE,
        posterPath TEXT,
        categoryPath TEXT NOT NULL,
        duration TEXT NOT NULL,
        isFavorite INTEGER NOT NULL,
        addedAt INTEGER NOT NULL,
        lastPlayedAt INTEGER,
        continuePosition INTEGER NOT NULL
      )
    ''');
  }

  Database get _db {
    if (_database == null) {
      throw Exception('Database has not been initialized.');
    }
    return _database!;
  }

  Future<void> setSetting(String key, String value) async {
    await _db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final rows = await _db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['value'] as String?;
  }

  Future<void> saveCategory(MediaCategory category) async {
    await _db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveItem(MediaItem item) async {
    await _db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MediaCategory>> loadCategories() async {
    final rows = await _db.query('categories', orderBy: 'name COLLATE NOCASE');
    return rows.map((map) => MediaCategory.fromMap(map)).toList();
  }

  Future<List<MediaItem>> loadItems() async {
    final rows = await _db.query('items', orderBy: 'addedAt DESC');
    return rows.map((map) => MediaItem.fromMap(map)).toList();
  }

  Future<void> clearLibrary({bool keepSettings = true}) async {
    await _db.delete('items');
    await _db.delete('categories');
    if (!keepSettings) {
      await _db.delete('settings');
    }
  }
}
