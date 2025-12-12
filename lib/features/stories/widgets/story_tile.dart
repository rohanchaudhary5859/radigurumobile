import 'package:flutter/material.dart';

class StoryTile extends StatelessWidget {
  final String avatar;
  final String username;
  final VoidCallback onTap;

  const StoryTile({
    super.key,
    required this.avatar,
    required this.username,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage(avatar),
            ),
            const SizedBox(height: 4),
            Text(username, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
