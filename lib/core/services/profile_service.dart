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

  // Create or get conversation
  Future<String> createConversation(String user1, String user2) async {
    final res = await _client.rpc(
      'create_or_get_conversation',
      params: {'user1': user1, 'user2': user2},
    );

    if (res is List && res.isNotEmpty) {
      return res.first['conversation_id'];
    }

    if (res is Map && res.containsKey('conversation_id')) {
      return res['conversation_id'];
    }

    throw Exception('Invalid RPC response');
  }

  // Fetch messages
  Future<List<Map<String, dynamic>>> fetchMessages(String conversationId) async {
    final data = await _client
        .from('messages')
        .select('id, content, created_at, sender_id')
        .eq('conversation_id', conversationId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(data);
  }
}
