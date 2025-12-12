import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const NotificationTile({super.key, required this.data, required this.onTap});

  String _message() {
    final type = data['type'];
    final actor = data['profiles']['username'];

    switch (type) {
      case 'like':
        return "$actor liked your post";
      case 'comment':
        return "$actor commented on your post";
      case 'follow':
        return "$actor started following you";
      case 'message':
        return "$actor sent you a message";
      default:
        return "$actor interacted";
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = data['profiles']['avatar_url'];
    final read = data['read'] == true;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(backgroundImage: NetworkImage(avatar ?? "")),
      title: Text(_message()),
      subtitle: Text(data['created_at']),
      trailing: read ? null : const Icon(Icons.circle, color: Colors.blue, size: 10),
    );
  }
}
