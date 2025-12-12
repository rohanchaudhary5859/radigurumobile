import 'package:flutter/material.dart';

class UserPostTile extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onTap;

  const UserPostTile({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = (post['media_urls'] as List).isNotEmpty
        ? post['media_urls'][0]
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.black12,
        child: url == null
            ? const Icon(Icons.image, size: 40)
            : Image.network(url, fit: BoxFit.cover),
      ),
    );
  }
}
