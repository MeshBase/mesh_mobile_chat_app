part of 'chat_detail_bloc.dart';

sealed class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object> get props => [];
}

final class GetChatDetail extends ChatDetailEvent {
  final String chatId;

  const GetChatDetail({required this.chatId});

  @override
  List<Object> get props => [chatId];
}

final class SendChat extends ChatDetailEvent {
  final ChatDetailModel chatContent;

  const SendChat({required this.chatContent});

  @override
  List<Object> get props => [chatContent];
}

final class RecieveChat extends ChatDetailEvent {
  final ChatDetailModel chatContent;

  const RecieveChat({required this.chatContent});

  @override
  List<Object> get props => [chatContent];
}
