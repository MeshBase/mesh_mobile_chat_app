import 'package:flutter/material.dart';
import 'package:mesh_mobile/common/widgets/list_item.dart';

class SearchUsersPage extends StatelessWidget {
  const SearchUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final users = <Map<String, dynamic>>[
      {
        "name": "Abebe Kebede",
        "statusMessage": "I'm doing good, how are you?",
        "isOnline": true,
        "initial": "A",
        "notificationCount": null,
      },
      {
        "name": "Asmamaw Demeke",
        "statusMessage": "Start a conversation",
        "isOnline": true,
        "initial": "A",
        "notificationCount": null,
      },
      {
        "name": "Bethel Shemsu",
        "statusMessage": "Start a conversation",
        "isOnline": true,
        "initial": "B",
        "notificationCount": null,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
