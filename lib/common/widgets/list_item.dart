import 'package:flutter/material.dart';

class UserListItem extends StatelessWidget {
  final String name;
  final String statusMessage;
  final bool isOnline;
  final String initial;
  final int? notificationCount;
  // onpressed
  final void Function()? onPressed;

  const UserListItem({
    super.key,
    required this.name,
    required this.statusMessage,
    required this.isOnline,
    required this.initial,
    this.notificationCount,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      hoverColor: Colors.grey.shade100,
      onTap: onPressed,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            initial,
            style: const TextStyle(
              fontWeight: FontWeight.w200,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        statusMessage,
        style: TextStyle(color: Colors.grey.shade500),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isOnline)
            const Text(
              "Online",
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          if (notificationCount != null)
            CircleAvatar(
              radius: 11,
              backgroundColor: Colors.red,
              child: Text(
                notificationCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
