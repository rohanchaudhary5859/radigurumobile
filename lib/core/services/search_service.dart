import 'package:supabase_flutter/supabase_flutter.dart';

class SearchService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Search doctors by username, full_name, specialization, and location
  Future<List<Map<String, dynamic>>> searchDoctors(
    String q, {
    String? location,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _client
        .from('profiles')
        .select(
          'id, username, full_name, specialization, hospital_name, avatar_url, location, created_at',
        )
        .or(
          'username.ilike.%$q%,full_name.ilike.%$q%,specialization.ilike.%$q%',
        )
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    // FIX: match() always works after OR
    if (location != null && location.isNotEmpty) {
      query = query.match({'location': location});
    }

    final data = await query;
    return List<Map<String, dynamic>>.from(data);
  }

  /// Search posts by caption and media type
  Future<List<Map<String, dynamic>>> searchPosts(
    String q, {
    String mediaType = 'image',
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _client
        .from('posts')
        .select(
          'id, author_id, caption, media_urls, media_type, created_at, profiles(username, avatar_url)',
        )
        .ilike('caption', '%$q%')
        .eq('media_type', mediaType)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Suggest usernames or topics
  Future<List<String>> suggest(
    String q, {
    int limit = 10,
  }) async {
    if (q.isEmpty) return [];

    final userList = await _client
        .from('profiles')
        .select('username')
        .ilike('username', '%$q%')
        .limit(limit);

    final topicList = await _client
        .from('topics')
        .select('name')
        .ilike('name', '%$q%')
        .limit(limit);

    final results = <String>{};

    for (final user in userList) {
      results.add(user['username']);
    }

    for (final topic in topicList) {
      results.add(topic['name']);
    }

    return results.take(limit).toList();
  }
}
