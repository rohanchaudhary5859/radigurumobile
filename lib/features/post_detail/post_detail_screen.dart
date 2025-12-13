import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_router_args.dart';
import '../comments/comments_screen.dart';
import 'post_detail_controller.dart';
import 'widgets/post_actions_row.dart';
import '../../features/follow/widgets/follow_button.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostDetailArgs? args;
  const PostDetailScreen({super.key, this.args});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(postDetailControllerProvider.notifier).loadPost(widget.args?.postId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postDetailControllerProvider);
    final post = state.post;

    if (state.loading || post == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final author = post['profiles'] ?? {};
    final media = (post['media_urls'] as List<dynamic>?)?.cast<String>() ?? [];
    final firstMedia = media.isNotEmpty ? media[0] : null;
    final createdAt = post['created_at'] != null ? DateTime.parse(post['created_at']) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(author['username'] ?? 'Post'),
        actions: [
          if (post['author_id'] != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FollowButton(targetId: post['author_id']),
            )
        ],
      ),
      body: ListView(
        children: [
          // Media
          if (firstMedia != null)
            AspectRatio(aspectRatio: 1, child: Image.network(firstMedia, fit: BoxFit.cover)),

          // Actions row
          PostActionsRow(
            liked: state.likedByMe,
            saved: state.savedByMe,
            onLike: () => ref.read(postDetailControllerProvider.notifier).toggleLike(widget.args?.postId ?? ''),
            onComment: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CommentsScreen(args: CommentsArgs(postId: widget.args?.postId ?? ''))));
            },
            onSave: () => ref.read(postDetailControllerProvider.notifier).toggleSave(widget.args?.postId ?? ''),
            onShare: () {
              // Simple share: copy link or share via system - placeholder
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share action')));
            },
          ),

          // Likes count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('${state.likesCount} likes', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),

          // Caption
          if ((post['caption'] ?? '').toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: author['username'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    const TextSpan(text: '  '),
                    TextSpan(text: post['caption'] ?? '', style: const TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ),

          // Timestamp
          if (createdAt != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
              child: Text(DateFormat.yMMMd().add_jm().format(createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),

          const Divider(),

          // Comments preview (first few)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('Comments', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),

          ...state.comments.take(5).map((c) {
            final profile = c['profiles'] ?? {};
            return ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(profile['avatar_url'] ?? "")),
              title: Text(profile['username'] ?? 'User'),
              subtitle: Text(c['content'] ?? ''),
            );
          }),

          if (state.comments.length > 5)
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CommentsScreen(args: CommentsArgs(postId: widget.args?.postId ?? ''))));
              },
              child: const Text('View all comments'),
            ),

          const SizedBox(height: 20),
        ],
      ),

      // Bottom input to add a comment inline
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentCtrl,
                  decoration: const InputDecoration(hintText: 'Add a comment...', border: InputBorder.none),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  final text = _commentCtrl.text.trim();
                  if (text.isEmpty) return;
                  await ref.read(postDetailControllerProvider.notifier).addComment(widget.args?.postId ?? '', text);
                  _commentCtrl.clear();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
