import 'package:flutter/material.dart';
import 'package:mesh_mobile/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:go_router/go_router.dart';

class ChatDetailPage extends StatefulWidget {
  ChatDetailPage({super.key});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final List<Map<String, dynamic>> chatText = [
    {
      "textTime": DateTime.now(),
      "bubbleContent": "Hello",
      "isSender": false,
    },
    {
      "textTime": DateTime.now(),
      "bubbleContent": "Hi",
      "isSender": true,
    },
    {
      "textTime": DateTime.now(),
      "bubbleContent": "How are you?",
      "isSender": false,
    },
    {
      "textTime": DateTime.now(),
      "bubbleContent": "I'm doing good, how are you?",
      "isSender": true,
    }
  ];
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top section of chat detail page
            _buildTopSection(context),

            // Body Section
            Expanded(
              child: ListView.builder(
                itemCount: chatText.length,
                itemBuilder: (context, index) {
                  final chatBubble = chatText[index];
                  return ChatBubble(
                    textTime: chatBubble["textTime"],
                    bubbleContent: chatBubble["bubbleContent"],
                    isSender: chatBubble["isSender"],
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
                    SizedBox(
                      width: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: InkWell(
                        onTap: () {},
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

  Widget _buildTopSection(context) {
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
                child: const Center(
                  child: Text(
                    "A",
                    style: TextStyle(
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
          const Expanded(
            child: Text(
              "Abe Kebe",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
