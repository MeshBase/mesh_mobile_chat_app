import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesh_mobile/common/widgets/list_item.dart';
import 'package:mesh_mobile/features/chat/domain/user_info_model.dart';
import 'package:mesh_mobile/route_names.dart';

class NearbyUsersPage extends StatelessWidget {
  const NearbyUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final users = <Map<String, dynamic>>[
      {
        "name": "Abebe Kebede",
        "statusMessage": "I'm doing good, how are you?",
        "isOnline": true,
        "initial": "A",
        "notificationCount": null,
        "chatId": 'c2029bb3-00d0-470a-a6e1-e7f834a55eca'
      },
      {
        "name": "Meron Kebede",
        "statusMessage": "Hello",
        "isOnline": true,
        "initial": "M",
        "notificationCount": 1,
        "chatId": 'f69cbaa4-c358-4063-b6d4-a5bf84bcc86c'
      },
      {
        "name": "Asmamaw Demeke",
        "statusMessage": "Start a conversation",
        "isOnline": true,
        "initial": "A",
        "notificationCount": null,
        "chatId": '13207541-8916-4b0c-84cf-cbb3dad351e0'
      },
      {
        "name": "Bethel Shemsu",
        "statusMessage": "Start a conversation",
        "isOnline": true,
        "initial": "B",
        "notificationCount": null,
        "chatId": '71a826df-1a1c-4a3c-bae4-c8feb075471a'
      },
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return UserListItem(
                  name: user['name']!,
                  statusMessage: user['statusMessage']!,
                  isOnline: user['isOnline']!,
                  initial: user['initial']!,
                  notificationCount: user['notificationCount'],
                  onPressed: () {
                    final data = UserInfoModel(
                        chatId: user['chatId'], name: user['name']);
                    context.push(Routes.chat, extra: data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
