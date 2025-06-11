import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mesh_base_flutter/mesh_base_flutter.dart';
import 'package:mesh_mobile/common/mesh_helpers/mesh_dto.dart';
import 'package:mesh_mobile/common/mesh_helpers/message_interactions_service.dart';
import 'package:mesh_mobile/database/database_helper.dart';
import 'package:mesh_mobile/features/chat/data/chat_repository.dart';
import 'package:mesh_mobile/features/chat/domain/chat_detail_model.dart';
import 'package:mesh_mobile/features/chat/domain/user_info_model.dart';

part 'chat_detail_event.dart';
part 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  MessageInteractionsListener? _messageInteractionsListener;
  final ChatRepository chatRepository;

  ChatDetailBloc({required this.chatRepository}) : super(ChatDetailInitial()) {
    on<GetChatDetail>(_fetchDataFromDb);
    on<SendChat>(_sendData);
    on<RecieveChat>(_receiveData);
  }

  FutureOr<void> _fetchDataFromDb(GetChatDetail event, emit) async {
    emit(ChatDetailLoading());

    _registerMessageListener();
    final myDeviceID = await MeshBaseFlutter().getId();
    await chatRepository.ensureUserExistsIfNoMessages(myDeviceID, event.chatId, event.model.name, event.model.userName);
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

        MessageInteractionsService.send(event.chatContent.content, chatState.chatId);

        await DatabaseHelper.storeMessage(
          chatId: chatState.chatId,
          senderId: chatState.chatId,
          content: event.chatContent.content,
          isSender: event.chatContent.isSender,
        );

        currentChat.add(event.chatContent);
        emit(ChatDetailLoaded(chats: currentChat, chatId: chatState.chatId));

    }
  }

  FutureOr<void> _receiveData(RecieveChat event, emit) async {
    if (state is ChatDetailLoaded) {
      final chatState = state as ChatDetailLoaded;
      final List<ChatDetailModel> currentChat = List.of(chatState.chats);

        await DatabaseHelper.storeMessage(
          chatId: chatState.chatId,
          senderId: chatState.chatId,
          content: event.chatContent.content,
          isSender: event.chatContent.isSender,
        );
        currentChat.add(event.chatContent);
        emit(ChatDetailLoaded(chats: currentChat, chatId: chatState.chatId));
    }
  }

  void _registerMessageListener() async {
    _messageInteractionsListener = (MessageDTO messageDto, String sourceUUID) async {
      final model = ChatDetailModel(isSender: false, content: messageDto.message,);
      debugPrint("[X]Chat Detail is aliveeeee");
      add(RecieveChat(chatContent: model));
    };
    
    MessageInteractionsService.addListener(_messageInteractionsListener!);
  }

}
