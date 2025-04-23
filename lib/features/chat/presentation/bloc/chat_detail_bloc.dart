import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mesh_mobile/features/chat/domain/chat_detail_model.dart';

part 'chat_detail_event.dart';
part 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  ChatDetailBloc() : super(ChatDetailInitial()) {
    on<GiveMeData>(_fetchDataFromDb);
    on<SendChat>(_sendData);
    on<RecieveChat>(_recieveData);
  }

  FutureOr<void> _fetchDataFromDb(event, emit) async {
    // simulate fetching data from sqflite or local storage
    emit(ChatDetailLoading());
    await Future.delayed(const Duration(seconds: 2));
    const List<ChatDetailModel> dummyData = [
      ChatDetailModel(content: "Hello", isSender: false),
      ChatDetailModel(content: "Hi", isSender: true),
      ChatDetailModel(content: "I'm doing good, how are you?", isSender: false)
    ];

    emit(const ChatDetailLoaded(chats: dummyData));
  }

  FutureOr<void> _sendData(SendChat event, emit) {
    if (state is ChatDetailLoaded) {
      final chatState = state as ChatDetailLoaded;
      final List<ChatDetailModel> currentChat = List.of(chatState.chats);
      currentChat.add(event.chatContent);
      emit(ChatDetailLoaded(chats: currentChat));
    }
  }

  FutureOr<void> _recieveData(RecieveChat event, emit) {
    if (state is ChatDetailLoaded) {
      final chatState = state as ChatDetailLoaded;
      final List<ChatDetailModel> currentChat = List.of(chatState.chats);
      currentChat.add(event.chatContent);
      emit(ChatDetailLoaded(chats: currentChat));
    }
  }
}
