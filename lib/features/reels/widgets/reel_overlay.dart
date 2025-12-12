import 'package:flutter/material.dart';

class ReelOverlay extends StatelessWidget {
  final Map<String, dynamic> reel;
  final VoidCallback onLike;

  const ReelOverlay({
    super.key,
    required this.reel,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final user = reel['profiles'];
    return Positioned(
      bottom: 50,
      right: 10,
      child: Column(
        children: [
          GestureDetector(
            onTap: onLike,
            child: const Icon(Icons.favorite, size: 34, color: Colors.white),
          ),
          Text(
            '${reel['likes'] ?? 0}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(user?['avatar_url'] ?? ''),
          ),
        ],
      ),
    );
  }
}
