import 'package:flutter/material.dart';

class PostActionsRow extends StatelessWidget {
  final bool liked;
  final bool saved;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const PostActionsRow({
    super.key,
    required this.liked,
    required this.saved,
    required this.onLike,
    required this.onComment,
    required this.onSave,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : null),
          onPressed: onLike,
        ),
        IconButton(icon: const Icon(Icons.mode_comment_outlined), onPressed: onComment),
        IconButton(icon: const Icon(Icons.share), onPressed: onShare),
        const Spacer(),
        IconButton(icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border), onPressed: onSave),
      ],
    );
  }
}
