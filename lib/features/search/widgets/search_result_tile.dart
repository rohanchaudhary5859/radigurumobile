import 'package:flutter/material.dart';

class SearchResultTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final String type; // 'doctor' or 'post'
  final VoidCallback? onTap;

  const SearchResultTile({super.key, required this.item, required this.type, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (type == 'doctor') {
      final avatar = item['avatar_url'] ?? '';
      final name = item['full_name'] ?? item['username'] ?? 'Unknown';
      final spec = item['specialization'] ?? '';
      final hospital = item['hospital_name'] ?? '';

      return ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null),
        title: Text(name),
        subtitle: Text('$spec • $hospital'),
        trailing: IconButton(icon: const Icon(Icons.person_add), onPressed: () {}),
      );
    } else {
      final media = (item['media_urls'] as List<dynamic>?) ?? [];
      final thumb = media.isNotEmpty ? media[0] as String : null;
      final caption = item['caption'] ?? '';

      return ListTile(
        onTap: onTap,
        leading: thumb == null ? null : Image.network(thumb, width: 56, height: 56, fit: BoxFit.cover),
        title: Text(caption, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(item['profiles']?['username'] ?? ''),
      );
    }
  }
}
