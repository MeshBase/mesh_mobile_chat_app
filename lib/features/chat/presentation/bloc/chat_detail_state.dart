part of 'chat_detail_bloc.dart';

sealed class ChatDetailState extends Equatable {
  const ChatDetailState();

  @override
  List<Object> get props => [];
}

final class ChatDetailInitial extends ChatDetailState {}

final class ChatDetailLoading extends ChatDetailState {}

final class ChatDetailLoaded extends ChatDetailState {
  final List<ChatDetailModel> chats;

  const ChatDetailLoaded({required this.chats});

  @override
  List<Object> get props => [chats];
}
