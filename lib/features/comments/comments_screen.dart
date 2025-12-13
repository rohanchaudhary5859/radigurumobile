import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app_router_args.dart';
import 'comment_controller.dart';
import 'widgets/comment_tile.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final CommentsArgs? args;

  const CommentsScreen({super.key, this.args});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _input = TextEditingController();
  String? replyingTo;

  @override
  void initState() {
    super.initState();
    ref.read(commentControllerProvider.notifier).loadComments(widget.args?.postId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Comments',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to comment',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.comments.length,
                        itemBuilder: (context, i) {
                          final c = state.comments[i];

                          // Null safety
                          final currentUser = Supabase.instance.client.auth.currentUser;
                          final isMine = currentUser != null && c['author_id'] == currentUser.id;

                          return CommentTile(
                            comment: c,
                            onReply: () {
                              setState(() => replyingTo = c['id']);
                            },
                            onLike: () {
                              ref.read(commentControllerProvider.notifier).like(c['id'], widget.args?.postId ?? '');
                            },
                            onDelete: isMine
                                ? () {
                                    ref.read(commentControllerProvider.notifier).deleteComment(
                                          c['id'],
                                          widget.args?.postId ?? '',
                                        );
                                  }
                                : null,
                          );
                        },
                      ),
          ),

          // Reply indicator
          if (replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  const Text(
                    'Replying to comment',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => replyingTo = null),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

          // Input bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: Supabase.instance.client.auth.currentUser?.userMetadata?['avatar_url'] != null
                      ? NetworkImage(Supabase.instance.client.auth.currentUser!.userMetadata!['avatar_url'])
                      : null,
                  child: Supabase.instance.client.auth.currentUser?.userMetadata?['avatar_url'] == null
                      ? const Icon(Icons.person, size: 24)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: InputDecoration(
                      hintText: replyingTo == null
                          ? "Add a comment..."
                          : "Write a reply...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () async {
                    if (_input.text.trim().isEmpty) return;

                    await ref.read(commentControllerProvider.notifier).addComment(
                          widget.args?.postId ?? '',
                          _input.text.trim(),
                          parentId: replyingTo,
                        );

                    setState(() {
                      replyingTo = null;
                      _input.clear();
                    });
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
