import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';

class PostService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch feed with pagination
  Future<List<Map<String, dynamic>>> fetchFeed({
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _client
        .from('posts')
        .select(
            'id, author_id, caption, media_urls, media_type, created_at, profiles (username, avatar_url)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Upload media to Supabase Storage
  Future<String> uploadMedia(File file, String userId) async {
    final bucket = 'posts';
    final ext = _extFromPath(file.path);
    final path = 'posts/$userId/${DateTime.now().millisecondsSinceEpoch}$ext';
    final contentType = lookupMimeType(file.path) ?? 'application/octet-stream';

    // Optional cleanup
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (_) {}

    await _client.storage.from(bucket).uploadBinary(
          path,
          await file.readAsBytes(),
          fileOptions: FileOptions(contentType: contentType),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// Create new post
  Future<void> createPost({
    required String authorId,
    required String caption,
    required List<String> mediaUrls,
    required String mediaType,
    String? location,
  }) async {
    await _client.from('posts').insert({
      'author_id': authorId,
      'caption': caption,
      'media_urls': mediaUrls,
      'media_type': mediaType,
      'location': location,
    });
  }

  /// Like / Unlike a post
  Future<bool> toggleLike(String postId, String userId) async {
    final existing = await _client
        .from('post_likes')
        .select()
        .filter('post_id', 'eq', postId)
        .filter('user_id', 'eq', userId)
        .maybeSingle();

    if (existing == null) {
      await _client.from('post_likes').insert({
        'post_id': postId,
        'user_id': userId,
      });
      return true;
    } else {
      await _client
          .from('post_likes')
          .delete()
          .filter('post_id', 'eq', postId)
          .filter('user_id', 'eq', userId);
      return false;
    }
  }

  /// Get exact likes count
  Future<int> getLikesCount(String postId) async {
    final res = await _client
        .from('post_likes')
        .select('id')
        .filter('post_id', 'eq', postId);

    return res.length;
  }

  /// Fetch comments of a post
  Future<List<Map<String, dynamic>>> fetchComments(
    String postId, {
    int limit = 50,
  }) async {
    final data = await _client
        .from('comments')
        .select(
            'id, content, author_id, created_at, profiles(username, avatar_url)')
        .filter('post_id', 'eq', postId)
        .order('created_at', ascending: true)
        .limit(limit);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Add a comment
  Future<void> addComment(String postId, String userId, String content) async {
    await _client.from('comments').insert({
      'post_id': postId,
      'author_id': userId,
      'content': content,
    });
  }

  /// Save / Unsave Post
  Future<bool> toggleSave(String postId, String userId) async {
    final existing = await _client
        .from('post_saves')
        .select()
        .filter('post_id', 'eq', postId)
        .filter('user_id', 'eq', userId)
        .maybeSingle();

    if (existing == null) {
      await _client.from('post_saves').insert({
        'post_id': postId,
        'user_id': userId,
      });
      return true;
    } else {
      await _client
          .from('post_saves')
          .delete()
          .filter('post_id', 'eq', postId)
          .filter('user_id', 'eq', userId);
      return false;
    }
  }

  /// Extract file extension
  String _extFromPath(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return '.jpg';
    return path.substring(idx);
  }
}
