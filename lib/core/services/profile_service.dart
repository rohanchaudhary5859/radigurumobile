import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select('*')
        .filter('id', 'eq', userId)
        .single();
    return Map<String, dynamic>.from(data);
  }

  Future<void> upsertProfile(Map<String, dynamic> profile) async {
    await _client
        .from('profiles')
        .upsert(profile);
  }

  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    final data = await _client
        .from('posts')
        .select('*')
        .filter('author_id', 'eq', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getUserReels(String userId) async {
    final data = await _client
        .from('reels')
        .select('*')
        .filter('author_id', 'eq', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getSavedPosts(String userId) async {
    final data = await _client
        .from('post_saves')
        .select('posts(*)')
        .filter('user_id', 'eq', userId);
    return List<Map<String, dynamic>>.from(data);
  }
}
