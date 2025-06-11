import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_mobile/common/repositories/message_repository.dart';
import 'package:mesh_mobile/features/chat/data/chat_repository.dart';
import 'package:mesh_mobile/features/chat/domain/chat_summary.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository chatRepository;
  final MessageRepository messageRepository;

  ChatListBloc({
    required this.chatRepository,
    required this.messageRepository,
  }) : super(ChatListInitial()) {
    on<LoadChatList>(_onLoadChatList);
    on<RefreshChatList>(_onLoadChatList);

    _startListeningToMessages();
  }

  Future<void> _onLoadChatList(
      ChatListEvent event, Emitter<ChatListState> emit) async {
    emit(ChatListLoading());

    try {
      final chats = await chatRepository.fetchChatSummaries();
      emit(ChatListLoaded(chats));
    } catch (e) {
      emit(ChatListError('Failed to load chats, Exception: ${e.toString()}'));
    }
  }

  void _startListeningToMessages() {
    messageRepository.messageStream.listen((message) {
      add(LoadChatList());
    });
  }
}
