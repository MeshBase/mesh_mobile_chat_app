import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mesh_base_flutter/mesh_base_flutter.dart';
import 'package:mesh_mobile/database/database_helper.dart';
import 'package:mesh_mobile/features/chat/domain/chat_detail_model.dart';

part 'chat_detail_event.dart';
part 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final mesh = MeshBaseFlutter();
  ChatDetailBloc() : super(ChatDetailInitial()) {
    on<GetChatDetail>(_fetchDataFromDb);
    on<SendChat>(_sendData);
    on<RecieveChat>(_recieveData);
  }

  _initMesh() async {
    try {
      await mesh.turnOn(); //No effect if already on
      mesh.subscribe(MeshManagerListener(onDataReceivedForSelf: (data) {
        if (state is ChatDetailLoaded &&
            (state as ChatDetailLoaded).chatId == data.sender) {}
      }));
    } catch (e) {
      debugPrint('[X] Error turning on mesh: $e');
    }
  }

  FutureOr<void> _fetchDataFromDb(GetChatDetail event, emit) async {
    emit(ChatDetailLoading());
    await DatabaseHelper.db;
    final messageData = await DatabaseHelper.getMessagesByChatId(event.chatId);

    List<ChatDetailModel> dummyData = [
      const ChatDetailModel(content: "Hello", isSender: false),
      const ChatDetailModel(content: "Hi", isSender: true),
      const ChatDetailModel(
          content: "I'm doing good, how are you?", isSender: false)
    ];

    for (var message in messageData) {
      dummyData.add(ChatDetailModel(
          isSender: message['isSender'] == 1, content: message['content']));
    }
    emit(ChatDetailLoaded(chats: dummyData, chatId: event.chatId));
  }

  FutureOr<void> _sendData(SendChat event, emit) async {
    if (state is ChatDetailLoaded) {
      final chatState = state as ChatDetailLoaded;
      final List<ChatDetailModel> currentChat = List.of(chatState.chats);
      await DatabaseHelper.storeMessage(
        chatId: chatState.chatId,
        senderId: 'placeholder', // Unnecessary data for now
        content: event.chatContent.content,
        isSender: event.chatContent.isSender,
      );
      currentChat.add(event.chatContent);
      emit(ChatDetailLoaded(chats: currentChat, chatId: chatState.chatId));
    }
  }

  FutureOr<void> _recieveData(RecieveChat event, emit) async {
    if (state is ChatDetailLoaded) {
      final chatState = state as ChatDetailLoaded;
      final List<ChatDetailModel> currentChat = List.of(chatState.chats);
      await DatabaseHelper.storeMessage(
        chatId: chatState.chatId,
        senderId: 'placeholder', // Unnecessary data for now
        content: event.chatContent.content,
        isSender: event.chatContent.isSender,
      );
      currentChat.add(event.chatContent);
      emit(ChatDetailLoaded(chats: currentChat, chatId: chatState.chatId));
    }
  }
}
