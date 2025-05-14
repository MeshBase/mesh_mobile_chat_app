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

  ChatSummary copyWith({
    String? chatId,
    String? name,
    String? username,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? initial,
    bool? isOnline,
    int? unreadCount,
  }) {
    return ChatSummary(
      chatId: chatId ?? this.chatId,
      name: name ?? this.name,
      username: username ?? this.username,
      initial: initial ?? this.initial,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isOnline: isOnline ?? this.isOnline,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

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
