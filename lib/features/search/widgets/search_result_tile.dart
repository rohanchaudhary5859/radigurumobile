import 'package:flutter/material.dart';

class SearchResultTile extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback? onTap;

  const SearchResultTile({super.key, required this.result, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Check if this is a doctor/profile result
    if (result.containsKey('username') || result.containsKey('full_name')) {
      final avatar = result['avatar_url'] ?? '';
      final name = result['full_name'] ?? result['username'] ?? 'Unknown';
      final spec = result['specialization'] ?? '';
      final hospital = result['hospital_name'] ?? '';

      return ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null),
        title: Text(name),
        subtitle: Text('$spec • $hospital'),
        trailing: IconButton(icon: const Icon(Icons.person_add), onPressed: () {}),
      );
    } else {
      // This is a post result
      final media = (result['media_urls'] as List<dynamic>?) ?? [];
      final thumb = media.isNotEmpty ? media[0] as String : null;
      final caption = result['caption'] ?? '';

      return ListTile(
        onTap: onTap,
        leading: thumb == null ? null : Image.network(thumb, width: 56, height: 56, fit: BoxFit.cover),
        title: Text(caption, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(result['profiles']?['username'] ?? ''),
      );
    }
  }
}
