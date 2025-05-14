import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_mobile/common/mesh_helpers/mesh_dto.dart';
import 'package:mesh_mobile/common/mesh_helpers/message_interactions.dart';
import 'package:mesh_mobile/common/mesh_helpers/nearyby_discovery.dart';
import 'package:mesh_mobile/database/database_helper.dart';
import 'package:mesh_mobile/features/chat/data/chat_repository.dart';
import 'package:mesh_mobile/features/chat/domain/chat_summary.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

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

      //listen to online statuses
      await NearbyDiscovery.addListener((identities) async {
        final onlineUUIDs = <String>{};
        for (var (uuid, _) in identities) {
          onlineUUIDs.add(uuid);
        }
        final chats = (await chatRepository.fetchChatSummaries()).map((chat) {
          return chat.copyWith(isOnline: onlineUUIDs.contains(chat.chatId));
        }).toList();
        emit(ChatListLoaded(chats));
      });

      //listen to incoming messages even when chat detail is not opened
      await MessageInteractions.addListener((messageDto, sourceUUID) async {
        final chats = await chatRepository.fetchChatSummaries();

        ChatSummary? chat =
            chats.where((chat) => chat.chatId == sourceUUID).isNotEmpty
                ? chats.firstWhere((chat) => chat.chatId == sourceUUID)
                : null;

        BroadcastedIdentityDTO? identity = NearbyDiscovery.getIdentities()
            .where((identity) => identity.$1 == sourceUUID);

        await DatabaseHelper.db;
        if (chat == null) {
          await DatabaseHelper.createUser(
              userID: sourceUUID,
              name: identity?.name ?? 'Unknown',
              username: identity?.userName ?? 'unknown');
        }

        //TODO: remove placeholder
        await DatabaseHelper.storeMessage(
            chatId: sourceUUID,
            senderId: 'placeholder',
            content: messageDto.message,
            isSender: false);
      });

      emit(ChatListLoaded(chats));
    } catch (e) {
      emit(ChatListError('Failed to load chats, Exception: ${e.toString()}'));
    }
  }

  _listenOnlineStatuses() async {}
}
