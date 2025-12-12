import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/notification_service.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>(
  (ref) => NotificationController(ref),
);

class NotificationState {
  final bool loading;
  final List<Map<String, dynamic>> notifications;
  final String? error;

  NotificationState({
    this.loading = false,
    this.notifications = const [],
    this.error,
  });

  NotificationState copyWith({
    bool? loading,
    List<Map<String, dynamic>>? notifications,
    String? error,
  }) {
    return NotificationState(
      loading: loading ?? this.loading,
      notifications: notifications ?? this.notifications,
      error: error ?? this.error,
    );
  }
}

class NotificationController extends StateNotifier<NotificationState> {
  final Ref ref;
  final NotificationService _service = NotificationService();
  final SupabaseClient _client = Supabase.instance.client;

  RealtimeChannel? _channel;

  NotificationController(this.ref) : super(NotificationState()) {
    _init();
  }

  String? get userId => _client.auth.currentUser?.id;

  Future<void> _init() async {
    if (userId == null) return;
    await load();
    _subscribe();
  }

  // ---------------------
  // Load notifications
  // ---------------------
  Future<void> load() async {
    if (userId == null) return;

    state = state.copyWith(loading: true);
    try {
      final list = await _service.fetchNotifications(userId!);
      state = state.copyWith(loading: false, notifications: list);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // ---------------------
  // Mark notifications as read
  // ---------------------
  Future<void> markRead(String id) async {
    await _service.markRead(id);
    await load();
  }

  // ---------------------
  // Realtime subscription (Supabase v2)
  // ---------------------
  void _subscribe() {
    _channel?.unsubscribe();

    _channel = _client
        .channel('notifications:user_$userId')
        .onPostgresChanges(
          event: 'INSERT',
          schema: 'public',
          table: 'notifications',
          callback: (payload) async {
            final record =
                Map<String, dynamic>.from(payload.record ?? {});

            // Only refresh if notification belongs to current user
            if (record['receiver_id'] == userId) {
              await load();
            }
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
