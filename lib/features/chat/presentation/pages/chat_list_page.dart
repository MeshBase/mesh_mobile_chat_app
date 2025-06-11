import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mesh_mobile/common/widgets/list_item.dart';
import 'package:mesh_mobile/features/chat/domain/user_info_model.dart';
import 'package:mesh_mobile/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:mesh_mobile/route_names.dart';
import 'package:mesh_mobile/route_observer.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with RouteAware {
  late final ChatListBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<ChatListBloc>();
    bloc.add(LoadChatList());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    bloc.add(LoadChatList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatListBloc, ChatListState>(builder: (context, state) {
      switch (state) {
        case ChatListInitial() || ChatListLoading():
          return const Center(child: CircularProgressIndicator());
        case ChatListLoaded():
          final chats = state.chats;
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return UserListItem(
                  name: chat.name,
                  statusMessage: chat.lastMessage.isEmpty
                      ? 'Start a Conversation'
                      : chat.lastMessage,
                  isOnline: chat.isOnline,
                  initial: chat.initial,
                  notificationCount:
                      chat.unreadCount > 0 ? chat.unreadCount : null,
                  onPressed: () {
                    final UserInfoModel data = UserInfoModel(
                      name: chat.name,
                      chatId: chat.chatId,
                      userId: chat.chatId,
                      userName: chat.username,
                    );
                    context.push(Routes.chat, extra: data);
                  },
                );
              },
            ),
          );
        default:
          return Center(child: Text('Unhandled state $state'));
      }
    });
  }
}
