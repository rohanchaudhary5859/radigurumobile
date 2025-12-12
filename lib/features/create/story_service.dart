import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryService {
  final _client = Supabase.instance.client;

  Future<void> uploadStory({
    required File file,
    required String mediaType,
    required String caption,
  }) async {
    final userId = _client.auth.currentUser!.id;

    // Upload file to storage
    final fileExt = file.path.split('.').last;
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.$fileExt";

    final storagePath = "stories/$userId/$fileName";

    await _client.storage.from("stories").upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = _client.storage.from("stories").getPublicUrl(storagePath);

    // Insert database record
    await _client.from("stories").insert({
      "user_id": userId,
      "media_url": url,
      "media_type": mediaType,
      "caption": caption,
      "created_at": DateTime.now().toIso8601String(),
    });
  }
}
