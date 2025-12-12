import 'package:flutter/material.dart';

class CommentTile extends StatelessWidget {
  final Map<String, dynamic> comment;
  final VoidCallback onReply;
  final VoidCallback onLike;
  final VoidCallback? onDelete;

  const CommentTile({
    super.key,
    required this.comment,
    required this.onReply,
    required this.onLike,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final user = comment['profiles'];
    final avatar = user?['avatar_url'] ?? "";
    final username = user?['username'] ?? "User";
    final isReply = comment['parent_id'] != null;

    return Padding(
      padding: EdgeInsets.only(left: isReply ? 40 : 10, top: 10, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: avatar.isNotEmpty
                ? NetworkImage(avatar)
                : null,
            child: avatar.isEmpty ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(comment['content'] ?? ""),

                Row(
                  children: [
                    TextButton(
                      onPressed: onReply,
                      child: const Text("Reply"),
                    ),
                    const SizedBox(width: 10),

                    TextButton(
                      onPressed: onLike,
                      child: Text("Like (${comment['likes'] ?? 0})"),
                    ),

                    if (onDelete != null)
                      TextButton(
                        onPressed: onDelete,
                        child: const Text("Delete"),
                      ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
