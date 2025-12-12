import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/post_service.dart';
import '../../core/services/storage_service.dart';

final feedControllerProvider =
    StateNotifierProvider<FeedController, FeedState>(
  (ref) => FeedController(ref),
);

class FeedState {
  final bool loading;
  final List<Map<String, dynamic>> posts;
  final String? error;
  final bool hasMore;

  const FeedState({
    this.loading = false,
    this.posts = const [],
    this.error,
    this.hasMore = true,
  });

  FeedState copyWith({
    bool? loading,
    List<Map<String, dynamic>>? posts,
    String? error,
    bool? hasMore,
  }) {
    return FeedState(
      loading: loading ?? this.loading,
      posts: posts ?? this.posts,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class FeedController extends StateNotifier<FeedState> {
  final Ref ref;
  final PostService _service = PostService();
  final StorageService _storage = StorageService();
  final SupabaseClient _client = Supabase.instance.client;

  int page = 0;
  final int limit = 20;

  RealtimeChannel? _channel;

  FeedController(this.ref) : super(const FeedState()) {
    _init();
  }

  String? get userId => _client.auth.currentUser?.id;

  Future<void> _init() async {
    await loadMore(reset: true);
    _subscribeRealtime();
  }

  Future<void> loadMore({bool reset = false}) async {
    if (reset) {
      page = 0;
      state = state.copyWith(loading: true, error: null);
    } else {
      if (!state.hasMore || state.loading) return;
      state = state.copyWith(loading: true);
    }

    try {
      final offset = page * limit;

      final fetched =
          await _service.fetchFeed(limit: limit, offset: offset);

      final merged = reset ? fetched : [...state.posts, ...fetched];

      state = state.copyWith(
        loading: false,
        posts: merged,
        hasMore: fetched.length == limit,
      );

      if (fetched.length == limit) page++;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadMore(reset: true);
  }

  Future<void> createPost({
    required String caption,
    File? mediaFile,
    required String mediaType,
  }) async {
    if (userId == null) throw Exception("Not authenticated");

    state = state.copyWith(loading: true, error: null);

    try {
      List<String> mediaUrls = [];

      if (mediaFile != null) {
        final url = await _service.uploadMedia(
          mediaFile,
          userId!,
        );
        mediaUrls.add(url);
      }

      // Create post
      await _service.createPost(
        authorId: userId!,
        caption: caption,
        mediaUrls: mediaUrls,
        mediaType: mediaType,
      );

      await refresh();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> toggleLike(String postId) async {
    if (userId == null) return;

    try {
      await _service.toggleLike(postId, userId!);

      // small optimized update instead of refresh
      await refresh();
    } catch (e) {}
  }

  Future<void> toggleSave(String postId) async {
    if (userId == null) return;

    try {
      await _service.toggleSave(postId, userId!);

      // faster than full reload
      await refresh();
    } catch (_) {}
  }

  // -----------------------
  // Realtime Feed Updates
  // -----------------------
  void _subscribeRealtime() {
    _channel = _client.channel('public:posts').onPostgresChanges(
      event: 'INSERT',
      schema: 'public',
      table: 'posts',
      callback: (payload) {
        try {
          final newPost =
              Map<String, dynamic>.from(payload.record ?? {});

          // Prepend only unique posts
          if (!state.posts.any((p) => p['id'] == newPost['id'])) {
            state = state.copyWith(
              posts: [newPost, ...state.posts],
            );
          }
        } catch (_) {}
      },
    ).subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _channel = null;
    super.dispose();
  }
}
