import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app_router_args.dart';
import '../../../core/widgets/avatar.dart';
import '../../comments/comments_screen.dart';
import '../../post_detail/post_detail_screen.dart';
import '../controller/feed_controller.dart';

class FeedPost extends ConsumerWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  
  const FeedPost({
    super.key, 
    required this.post,
    this.onLike,
    this.onSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final author = post['profiles'] ?? {};
    final media =
        (post['media_urls'] as List<dynamic>?)?.cast<String>() ?? [];
    final firstMedia = media.isNotEmpty ? media.first : null;
    final postId = post['id']?.toString();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          ListTile(
            leading: Avatar(
              urlOrPath: author['avatar_url'],
              size: 44,
            ),
            title: Text(author['username'] ?? 'Unknown'),
            subtitle: Text(post['created_at'] ?? ''),
            trailing:
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ),

          // MEDIA PREVIEW
          if (firstMedia != null)
            GestureDetector(
              onTap: () {
                if (postId == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(args: PostDetailArgs(postId: postId)),
                  ),
                );
              },
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  firstMedia,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // CAPTION
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(post['caption'] ?? ''),
          ),

          // ACTION BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: onLike ?? () async {
                    if (postId != null) {
                      await ref
                          .read(feedControllerProvider.notifier)
                          .toggleLike(postId);
                    }
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    if (postId == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentsScreen(args: CommentsArgs(postId: postId)),
                      ),
                    );
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: onShare ?? () {
                    final caption = post['caption'] ?? '';
                    final authorName = author['username'] ?? 'Unknown';
                    final shareText = '$caption\n\n- by $authorName on Radiguru';
                    Share.share(shareText);
                  },
                ),

                const Spacer(),

                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: onSave ?? () async {
                    if (postId != null) {
                      await ref
                          .read(feedControllerProvider.notifier)
                          .toggleSave(postId);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
