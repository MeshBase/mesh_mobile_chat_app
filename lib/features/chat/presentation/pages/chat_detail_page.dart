import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_mobile/features/chat/domain/chat_detail_model.dart';
import 'package:mesh_mobile/features/chat/domain/user_info_model.dart';
import 'package:mesh_mobile/features/chat/presentation/bloc/chat_detail_bloc.dart';
import 'package:mesh_mobile/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:go_router/go_router.dart';

class ChatDetailPage extends StatefulWidget {
  final UserInfoModel userInfoModel;
  const ChatDetailPage({super.key, required this.userInfoModel});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context
        .read<ChatDetailBloc>()
        .add(GetChatDetail(chatId: widget.userInfoModel.chatId, model: widget.userInfoModel));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top section of chat detail page
            _buildTopSection(context, name: widget.userInfoModel.name),

            Expanded(
              child: BlocBuilder<ChatDetailBloc, ChatDetailState>(
                builder: (context, state) {
                  final bloc = context.read<ChatDetailBloc>();

                  if (state is ChatDetailInitial) {
                    bloc.add(GetChatDetail(chatId: widget.userInfoModel.chatId, model: widget.userInfoModel));
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatDetailLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatDetailLoaded) {
                    return ListView.builder(
                      itemCount: state.chats.length,
                      itemBuilder: (context, index) {
                        final chatBubble = state.chats[index];
                        return ChatBubble(
                          onTap: () => bloc.add(const RecieveChat(
                            chatContent: ChatDetailModel(
                              isSender: false,
                              content: 'Evolution',
                            ),
                          )),
                          textTime: DateTime.now(),
                          bubbleContent: chatBubble.content,
                          isSender: chatBubble.isSender,
                        );
                      },
                    );
                  }

                  return Center(
                    child: Text('Unimplemented state: $state'),
                  );
                },
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    const SizedBox(
                      height: 30,
                      width: 45,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Write a message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: InkWell(
                        onTap: () {
                          final message = _messageController.text.trim();
                          if (message.isNotEmpty) {
                            context.read<ChatDetailBloc>().add(SendChat(
                                chatContent: ChatDetailModel(
                                    content: message, isSender: true)));
                          }
                          _messageController.clear();
                        },
                        child: Container(
                          width: 47,
                          height: 47,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(context, {required String name}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              GoRouter.of(context).pop();
            },
          ),

          // User avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    name[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -5,
                right: -5,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          // user name
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          // online status
          const Text(
            "Online",
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
