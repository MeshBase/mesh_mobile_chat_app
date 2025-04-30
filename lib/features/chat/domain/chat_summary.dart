import 'package:equatable/equatable.dart';

class ChatSummary extends Equatable {
  final String chatId;
  final String name;
  final String username;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String initial;
  final bool isOnline;
  final int unreadCount;

  const ChatSummary({
    required this.chatId,
    required this.name,
    required this.username,
    required this.initial,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isOnline,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [
        chatId,
        username,
        name,
        lastMessage,
        lastMessageTime,
        initial,
        isOnline,
        unreadCount
      ];
}
