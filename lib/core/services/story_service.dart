import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';

class StoryService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> uploadStoryMedia(File file, String userId) async {
    const String bucket = 'stories';
    final ext = _ext(file.path);
    final path = 'stories/$userId/${DateTime.now().millisecondsSinceEpoch}$ext';
    final contentType = lookupMimeType(file.path) ?? 'application/octet-stream';

    await _client.storage.from(bucket).uploadBinary(
      path,
      await file.readAsBytes(),
      fileOptions: FileOptions(contentType: contentType),
    );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> createStory(String userId, String url, String mediaType) async {
    await _client.from('stories').insert({
      'author_id': userId,
      'media_url': url,
      'media_type': mediaType,
      'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchStories() async {
    final res = await _client
        .from('stories')
        .select('id, media_url, media_type, created_at, author_id, profiles(username, avatar_url)')
        .gte('expires_at', DateTime.now().toIso8601String())
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  String _ext(String p) {
    final i = p.lastIndexOf('.');
    return i == -1 ? '.jpg' : p.substring(i);
  }
}
