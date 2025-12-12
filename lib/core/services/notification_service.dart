import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchNotifications(String userId) async {
    final res = await _client
        .from('notifications')
        .select('''
          id,
          type,
          created_at,
          read,
          actor_id,
          extra,
          profiles!actor_id(username, avatar_url)
        ''')
        .eq('receiver_id', userId)
        .order('created_at', ascending: false);

    return (res as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> markRead(String notificationId) async {
    await _client.from('notifications').update({'read': true}).eq('id', notificationId);
  }
}
