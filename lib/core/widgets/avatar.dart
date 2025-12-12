import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Avatar extends StatelessWidget {
  final String? urlOrPath;
  final double size;
  final VoidCallback? onTap;

  const Avatar({super.key, this.urlOrPath, this.size = 64, this.onTap});

  bool _isLocalFile(String? p) {
    if (p == null) return false;
    return File(p).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (urlOrPath == null || urlOrPath!.isEmpty) {
      child = CircleAvatar(radius: size / 2, child: Icon(Icons.person, size: size / 2));
    } else if (_isLocalFile(urlOrPath)) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.file(File(urlOrPath!), width: size, height: size, fit: BoxFit.cover),
      );
    } else {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: urlOrPath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => CircleAvatar(radius: size / 2),
          errorWidget: (_, __, ___) => CircleAvatar(radius: size / 2, child: Icon(Icons.person)),
        ),
      );
    }

    return GestureDetector(onTap: onTap, child: SizedBox(width: size, height: size, child: child));
  }
}
