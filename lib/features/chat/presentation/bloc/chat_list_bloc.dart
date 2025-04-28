import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_mobile/features/chat/data/chat_repository.dart';
import 'package:mesh_mobile/features/chat/domain/chat_summary.dart';

part 'chat_list_state.dart';
part 'chat_list_event.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository chatRepository;

  ChatListBloc({required this.chatRepository}) : super(ChatListInitial()) {
    on<LoadChatList>(_onLoadChatList);
    on<RefreshChatList>(_onLoadChatList);
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
}
