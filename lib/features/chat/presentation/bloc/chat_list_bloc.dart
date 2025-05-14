import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_base_flutter/mesh_base_flutter.dart';
import 'package:mesh_mobile/features/chat/data/chat_repository.dart';
import 'package:mesh_mobile/features/chat/domain/chat_summary.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository chatRepository;
  final MeshBaseFlutter mesh = MeshBaseFlutter();

  ChatListBloc({required this.chatRepository}) : super(ChatListInitial()) {
    _initMesh();
    on<LoadChatList>(_onLoadChatList);
    on<RefreshChatList>(_onLoadChatList);
  }

  Future<void> _onLoadChatList(
      ChatListEvent event, Emitter<ChatListState> emit) async {
    emit(ChatListLoading());

    try {
      emit(ChatListLoaded(await _compileSummaries()));
    } catch (e) {
      emit(ChatListError('Failed to load chats, Exception: ${e.toString()}'));
    }
  }

  _initMesh() async {
    try {
      await mesh.turnOn(); //No effect if already on
      mesh.subscribe(MeshManagerListener(onNeighborConnected: (device) {
        add(RefreshChatList());
      }));
    } catch (e) {
      debugPrint('[X] Error turning on mesh: $e');
    }
  }

  Future<List<ChatSummary>> _compileSummaries() async {
    final List<ChatSummary> chats = await chatRepository.fetchChatSummaries();
    List<Device> devices = await mesh.getNeighbors();

    final List<ChatSummary> newChats = [];

    for (var device in devices) {
      var found = false;
      for (var i = 0; i < chats.length; i++) {
        var chat = chats[i];
        if (device.uuid == chat.chatId) {
          chats[i] = chat.copyWith(isOnline: true);
          found = true;
          break;
        }
      }
      if (!found) {
        newChats.add(ChatSummary(
          chatId: device.uuid,
          name: device.name,
          username: '<unknown>',
          initial: device.name[0].toUpperCase(),
          lastMessage: '',
          lastMessageTime: DateTime.now(),
          isOnline: true,
        ));
      }
    }
    return [...chats, ...newChats];
  }
}
