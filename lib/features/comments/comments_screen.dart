import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'comment_controller.dart';
import 'widgets/comment_tile.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _input = TextEditingController();
  String? replyingTo;

  @override
  void initState() {
    super.initState();
    ref.read(commentControllerProvider.notifier).loadComments(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),

      body: Column(
        children: [
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
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
                          ref.read(commentControllerProvider.notifier).like(c['id'], widget.postId);
                        },
                        onDelete: isMine
                            ? () {
                                ref.read(commentControllerProvider.notifier).deleteComment(
                                      c['id'],
                                      widget.postId,
                                    );
                              }
                            : null,
                      );
                    },
                  ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.grey.shade200),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: InputDecoration(
                      hintText: replyingTo == null
                          ? "Add a comment..."
                          : "Replying...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_input.text.trim().isEmpty) return;

                    await ref.read(commentControllerProvider.notifier).addComment(
                          widget.postId,
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
