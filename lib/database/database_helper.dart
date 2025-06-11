import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static Database? _db;
  static const Uuid _uuid = Uuid();

  static Future<Database> get db async {
    if (_db != null) return _db!;
    //Only uncomment to force database recreation!
    // await deleteDatabase();
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationSupportDirectory();
    final path = join(documentsDirectory.path, 'chat_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        debugPrint("[X]Database created");
        await db.execute('''
        CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT,
            username TEXT
        )
        ''');
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            chatId TEXT,
            senderId TEXT,
            content TEXT,
            isSender INTEGER,
            timestamp TEXT
          )
        ''');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS registered_user (
          name TEXT,
          username TEXT
        )
      ''');

        await seedDummyUsers(db);
      },
    );
  }

  static Future<void> seedDummyUsers(Database db) async {
    // Insert dummy users for testing purposes. WILL BE REPLACED WITH ACTUAL DATA LATER
    final dummyUsers = [
      {'name': 'Alice', 'username': 'alice123'},
      {'name': 'Bob', 'username': 'bob456'},
      {'name': 'Charlie', 'username': 'charlie789'},
      {
        'id': 'b01b1320-6660-4076-b847-c675ce8cb5f7',
        'name': 'Charlie',
        'username': 'charlie789'
      },
    ];

    for (var user in dummyUsers) {
      await db.insert('users', {
        'id': user['id'] ?? _uuid.v4(),
        'name': user['name']!,
        'username': user['username']!,
      });
    }

    debugPrint("[X]Dummy users successfully seeded");
  }

  // ─────────────── USERS ───────────────
  static Future<String> createUser(
      {required String name, required String username, String? userID}) async {
    final dbClient = await db;
    final id = userID ?? _uuid.v4();
    await dbClient.insert('users', {
      'id': id,
      'name': name,
      'username': username,
    });
    return id;
  }

  static Future<Map<String, dynamic>?> getUser(String id) async {
    final dbClient = await db;
    final result =
        await dbClient.query('users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<int> updateUser(String id, String name, String username) async {
    final dbClient = await db;
    return await dbClient.update(
      'users',
      {'name': name, 'username': username},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteUser(String id) async {
    final dbClient = await db;
    return await dbClient.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────── MESSAGES ───────────────

  static Future<String> storeMessage({
    String? messageId,
    required String chatId,
    required String senderId,
    required String content,
    required bool isSender,
  }) async {
    final dbClient = await db;
    final id = messageId ?? _uuid.v4();

    await dbClient.insert('messages', {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'isSender': isSender ? 1 : 0,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return id;
  }

  static Future<List<Map<String, dynamic>>> getMessagesByChatId(
      String chatId) async {
    final dbClient = await db;
    return await dbClient.query(
      'messages',
      where: 'chatId = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );
  }

//for development purposes only, use to force adding new tables inside onInit()
  static Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationSupportDirectory();
    final path = join(documentsDirectory.path, 'chat_app.db');
    final dbFile = File(path);

    if (await dbFile.exists()) {
      debugPrint('[X] deleted db file');
      await dbFile.delete();
    } else {
      debugPrint('[X] no db file to delete, skipping');
    }
  }

  static Future<void> upsertRegisteredUser(String name, String userName) async {
    final dbClient = await db;
    await dbClient.delete('registered_user');
    await dbClient.insert('registered_user', {
      'name': name,
      'username': userName,
    });
  }

  static Future<({String name, String userName})?> getRegisteredUser() async {
    final dbClient = await db;
    final rows = await dbClient.query(
      'registered_user',
      limit: 1,
    );
    if (rows.isNotEmpty) {
      final name = rows.first['name'];
      final username = rows.first['username'];

      return (
        name: name.toString(),
        userName: username.toString(),
      );
    }
    return null;
  }
}
