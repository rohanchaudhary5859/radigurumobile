import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/message_service.dart';

final messageControllerProvider =
    StateNotifierProvider<MessageController, MessageState>(
  (ref) => MessageController(ref),
);

class MessageState {
  final bool loading;
  final List<Map<String, dynamic>> messages;
  final String? error;

  const MessageState({
    this.loading = false,
    this.messages = const [],
    this.error,
  });

  MessageState copyWith({
    bool? loading,
    List<Map<String, dynamic>>? messages,
    String? error,
  }) {
    return MessageState(
      loading: loading ?? this.loading,
      messages: messages ?? this.messages,
      error: error,
    );
  }
}

class MessageController extends StateNotifier<MessageState> {
  final Ref ref;
  final SupabaseClient _client = Supabase.instance.client;
  final MessageService _service = MessageService();

  RealtimeChannel? _channel;

  MessageController(this.ref) : super(const MessageState());

  String? get userId => _client.auth.currentUser?.id;

  // -------------------
  // Load all messages (initial)
  // -------------------
  Future<void> loadMessages(String conversationId) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final messages = await _service.fetchMessages(conversationId);

      state = state.copyWith(
        loading: false,
        messages: messages,
      );

      _subscribe(conversationId);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  // -------------------
  // Send a message
  // -------------------
  Future<void> send(String conversationId, String text) async {
    if (userId == null || text.trim().isEmpty) return;

    await _service.sendMessage(
      conversationId: conversationId,
      senderId: userId!,
      content: text.trim(),
    );
  }

  // -------------------
  // Real-time subscription
  // -------------------
  void _subscribe(String conversationId) {
    // Remove old subscription if exists
    _channel?.unsubscribe();

    _channel = _client
        .channel('messages:conversation_$conversationId')
        .onPostgresChanges(
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              final record =
                  Map<String, dynamic>.from(payload.record ?? {});

              // Append new message
              state = state.copyWith(
                messages: [...state.messages, record],
              );
            } catch (_) {}
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _channel = null;
    super.dispose();
  }
}
