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
}
