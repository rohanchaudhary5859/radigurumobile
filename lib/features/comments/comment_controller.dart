import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'comment_service.dart';

final commentControllerProvider =
    StateNotifierProvider<CommentController, CommentState>(
  (ref) => CommentController(),
);

class CommentState {
  final bool loading;
  final List<Map<String, dynamic>> comments;

  const CommentState({
    this.loading = false,
    this.comments = const [],
  });

  CommentState copyWith({
    bool? loading,
    List<Map<String, dynamic>>? comments,
  }) {
    return CommentState(
      loading: loading ?? this.loading,
      comments: comments ?? this.comments,
    );
  }
}

class CommentController extends StateNotifier<CommentState> {
  CommentController() : super(const CommentState());

  final _client = Supabase.instance.client;
  final _service = CommentService();

  Future<void> loadComments(String postId) async {
    state = state.copyWith(loading: true);
    final list = await _service.fetchComments(postId);
    state = state.copyWith(loading: false, comments: list);
  }

  Future<void> addComment(String postId, String content, {String? parentId}) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _service.addComment(
      postId: postId,
      authorId: user.id,
      content: content,
      parentId: parentId,
    );

    await loadComments(postId);
  }

  Future<void> like(String commentId, String postId) async {
    await _service.likeComment(commentId);
    await loadComments(postId);
  }

  Future<void> deleteComment(String id, String postId) async {
    await _service.deleteComment(id);
    await loadComments(postId);
  }
}
