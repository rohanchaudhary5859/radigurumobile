import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Uploads file to specified bucket and returns public URL
  Future<String> uploadFile({
    required String bucket,
    required File file,
    required String path, // e.g. "avatars/{userId}.jpg"
  }) async {
    final contentType = lookupMimeType(file.path) ?? 'application/octet-stream';

    // remove existing file (overwrite)
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (_) {}

    final res = await _client.storage.from(bucket).uploadBinary(
          path,
          await file.readAsBytes(),
          fileOptions: FileOptions(contentType: contentType),
        );

    if (res != null) {
      // build public URL
      final url = _client.storage.from(bucket).getPublicUrl(path);
      return url;
    }

    throw Exception('Upload failed');
  }
}
