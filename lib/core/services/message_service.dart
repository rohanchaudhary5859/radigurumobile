import 'package:supabase_flutter/supabase_flutter.dart';

class MessageService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get all conversations for current user
  Future<List<Map<String, dynamic>>> fetchConversations(String userId) async {
    final data = await _client
        .from('conversations')
        .select('''
          id,
          conversation_members!inner(user_id, profiles(username, avatar_url)),
          messages (id, content, created_at, sender_id)
        ''')
        .eq('conversation_members.user_id', userId)
        .order('messages.created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // Create a new conversation (if not exists)
  Future<String> createConversation(String user1, String user2) async {
    final result = await _client.rpc(
      'create_or_get_conversation',
      params: {'user1': user1, 'user2': user2},
    );

    if (result == null) {
      throw Exception('RPC returned null');
    }

    if (result is List && result.isNotEmpty) {
      return result.first['conversation_id'].toString();
    }

    if (result is Map && result.containsKey('conversation_id')) {
      return result['conversation_id'].toString();
    }

    throw Exception('Unexpected RPC output format');
  }

  // Fetch messages (with pagination support)
  Future<List<Map<String, dynamic>>> fetchMessages(
    String conversationId, {
    int? limit,
    int? offset,
    bool ascending = true,
  }) async {
    var query = _client
        .from('messages')
        .select('id, content, created_at, sender_id, metadata')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: ascending);

    // Supabase v2 pagination fix
    if (limit != null) {
      if (offset != null) {
        final from = offset;
        final to = offset + limit - 1;
        query = query.range(from, to);
      } else {
        query = query.limit(limit);
      }
    }

    final data = await query;

    return List<Map<String, dynamic>>.from(data);
  }
}
