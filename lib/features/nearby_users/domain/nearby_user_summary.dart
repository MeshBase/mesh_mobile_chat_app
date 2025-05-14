import 'package:equatable/equatable.dart';

class NearbyUserSummary extends Equatable {
  final String name;
  final String userId;
  final String username;
  final String initial;
  final bool isOnline;
  final int unreadCount;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  const NearbyUserSummary({
    required this.userId,
    required this.name,
    required this.username,
    required this.initial,
    required this.isOnline,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [
        username,
        name,
        lastMessage,
        lastMessageTime,
        initial,
        isOnline,
        unreadCount
      ];
}
