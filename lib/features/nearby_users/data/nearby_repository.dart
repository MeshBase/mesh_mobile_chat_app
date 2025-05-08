import 'package:mesh_mobile/database/database_helper.dart';
import 'package:mesh_mobile/features/nearby_users/domain/nearby_user_summary.dart';

class NearbyRepository {
  Future<NearbyUserSummary> fetchNearbyUserSummary(String userId) async {
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
        WHERE u.id = ?
        LIMIT 1;
    ''', [userId]);

    if (result.isNotEmpty) {
      final row = result.first;
      return NearbyUserSummary(
        userId: row['userId'] as String,
        name: row['name'] as String,
        username: row['username'] as String,
        initial: (row['name'] as String).isNotEmpty
            ? (row['name'] as String)[0]
            : "-",
        lastMessage: (row['lastMessage'] ?? 'No messages yet') as String,
        lastMessageTime: row['lastMessageTime'] != null
            ? DateTime.parse(row['lastMessageTime'] as String)
            : null,
        isOnline: false, // Placeholder, update with actual online status logic
      );
    } else {
      // Return dummy data if the user does not exist
      return NearbyUserSummary(
        userId: userId,
        name: 'Unknown User',
        username: 'unknown',
        initial: "-",
        lastMessage: null,
        lastMessageTime: null,
        isOnline: false,
      );
    }
  }
}
