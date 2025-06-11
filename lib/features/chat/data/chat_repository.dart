import 'package:flutter/material.dart';
import 'package:mesh_mobile/database/database_helper.dart';
import 'package:mesh_mobile/features/chat/domain/chat_summary.dart';

class ChatRepository {
  Future<List<ChatSummary>> fetchChatSummaries() async {
    final dbClient = await DatabaseHelper.db;

    final result = await dbClient.rawQuery('''
        SELECT 
            u.id AS userId,
            u.name,
            u.username,
            (
                SELECT chatId
                FROM messages
                WHERE (messages.senderId = u.id OR messages.chatId LIKE '%' || u.id || '%')
                ORDER BY timestamp DESC
                LIMIT 1
            ) AS chatId,
            (
                SELECT content
                FROM messages
                WHERE (messages.senderId = u.id OR messages.chatId LIKE '%' || u.id || '%')
                ORDER BY timestamp DESC
                LIMIT 1
            ) AS lastMessage,
            (
                SELECT timestamp
                FROM messages
                WHERE (messages.senderId = u.id OR messages.chatId LIKE '%' || u.id || '%')
                ORDER BY timestamp DESC
                LIMIT 1
            ) AS lastMessageTime
        FROM users u
        ORDER BY 
            CASE WHEN lastMessageTime IS NULL THEN 1 ELSE 0 END,
            lastMessageTime DESC; 
    ''');

    return result
        .map((row) => ChatSummary(
              chatId: row['userId'] as String,
              name: row['name'] as String,
              username: row['username'] as String,
              lastMessage:
                  (row['lastMessage'] ?? 'Start a conversation') as String,
              lastMessageTime: row['lastMessageTime'] != null
                  ? DateTime.parse(row['lastMessageTime'] as String)
                  : DateTime.fromMillisecondsSinceEpoch(0),
              initial: _getInitial(row['name'] as String),
              isOnline: false, // still hardcoded
            ))
        .toList();
  }

  static String _getInitial(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<String?> getDestinationUUID(String chatId, String myUUID) async {
    final db = await DatabaseHelper.db;
    final List<Map<String, dynamic>> result = await db.query(
      'messages',
      where: 'chatId = ? AND senderId != ?',
      whereArgs: [chatId, myUUID],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['senderId'] as String;
    }
    return null;
  }

  Future<void> ensureUserExistsIfNoMessages(
      String myId, String otherUserId, String name, String username) async {
    final db = await DatabaseHelper.db;

    // Check if there are messages between the two users (either direction)
    final messages = await db.query(
      'messages',
      where:
          '(senderId = ? AND chatId LIKE ?) OR (senderId = ? AND chatId LIKE ?)',
      whereArgs: [
        myId,
        '%$otherUserId%',
        otherUserId,
        '%$myId%',
      ],
      limit: 1,
    );

    if (messages.isEmpty) {
      // Check if the user already exists
      final existingUser = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [otherUserId],
        limit: 1,
      );

      if (existingUser.isEmpty) {
        // Create the user
        await DatabaseHelper.createUser(
          name: name,
          username: username,
          userID: otherUserId,
        );
        debugPrint('[X] Created new user $username with ID $otherUserId');
      } else {
        debugPrint('[X] User $otherUserId already exists, skipping insert');
      }
    } else {
      debugPrint('[X] Message(s) already exist between $myId and $otherUserId');
    }
  }
}
