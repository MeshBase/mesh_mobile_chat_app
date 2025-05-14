import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:mesh_mobile/common/mesh_helpers/message_interactions.dart';
import 'package:mesh_mobile/database/database_helper.dart';
import 'package:mesh_mobile/features/chat/domain/chat_detail_model.dart';

part 'chat_detail_event.dart';
part 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  MessageInteractionsListener? listener;

  ChatDetailBloc() : super(ChatDetailInitial()) {
    on<GetChatDetail>(_fetchData);
    on<SendChat>(_sendData);
    on<RecieveChat>(_recieveData);
  }

  FutureOr<void> _fetchData(GetChatDetail event, emit) async {
    emit(ChatDetailLoading());
    await DatabaseHelper.db;
    final messageData = await DatabaseHelper.getMessagesByChatId(event.chatId);

    List<ChatDetailModel> messages = [];

    for (var message in messageData) {
      messages.add(ChatDetailModel(
          isSender: message['isSender'] == 1, content: message['content']));
    }

    //Storing messages in Database is already handled in chat_list_bloc
    try {
      //To stop adding listeners whenever new chats are opened
      if (listener != null) MessageInteractions.removeListener(listener!);

      listener = (messageDto, sourceUUID) {
        if (state is ChatDetailLoaded &&
            (state as ChatDetailLoaded).chatId == sourceUUID) {
          add(RecieveChat(
              chatContent: ChatDetailModel(
                  isSender: false, content: messageDto.message)));
        }
      };

      MessageInteractions.addListener(listener!);
      await MessageInteractions.start();
    } catch (e) {
      //TODO: consider showing a snack bar when encountering errors
      debugPrint('[X] Could not load chat detail. Error:$e');
    }
    emit(ChatDetailLoaded(chats: messages, chatId: event.chatId));
  }

  FutureOr<void> _sendData(SendChat event, emit) async {
    if (state is ChatDetailLoaded) {
      final chatState = state as ChatDetailLoaded;
      final List<ChatDetailModel> currentChat = List.of(chatState.chats);
      try {
        await MessageInteractions.send(
            event.chatContent.content, chatState.chatId);
      } catch (e) {
        debugPrint('[X] Could not send message. Error:$e');
        return;
      }

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
      //Storing messages is handled by chat_list_bloc so that there is
      // no need to be in chat detail view to store messages
      currentChat.add(event.chatContent);
      emit(ChatDetailLoaded(chats: currentChat, chatId: chatState.chatId));
    }
  }
}
