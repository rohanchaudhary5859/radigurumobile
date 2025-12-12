import 'package:supabase_flutter/supabase_flutter.dart';

class CommentService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    final res = await _client
        .from('comments')
        .select('''
          id,
          post_id,
          parent_id,
          content,
          created_at,
          author_id,
          likes,
          profiles(id, username, avatar_url)
        ''')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> addComment({
    required String postId,
    required String authorId,
    required String content,
    String? parentId,
  }) async {
    await _client.from('comments').insert({
      'post_id': postId,
      'author_id': authorId,
      'content': content,
      'parent_id': parentId,
    });
  }

  Future<void> likeComment(String commentId) async {
    await _client.rpc('like_comment', params: {'comment_id': commentId});
  }

  Future<void> deleteComment(String id) async {
    await _client.from('comments').delete().eq('id', id);
  }
}
