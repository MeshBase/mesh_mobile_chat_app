part of 'chat_list_bloc.dart';

sealed class ChatListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadChatList extends ChatListEvent {}

class RefreshChatList extends ChatListEvent {}
