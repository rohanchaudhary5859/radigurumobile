import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      final fetched = await _client.from('posts').select().order('created_at', ascending: false).range(offset, offset + limit - 1);

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
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _client.storage.from('posts').upload(fileName, mediaFile);
        final url = _client.storage.from('posts').getPublicUrl(fileName);
        mediaUrls.add(url);
      }

      // Create post
      final res = await _client.from('posts').insert([
        {
          'author_id': userId,
          'caption': caption,
          'media_urls': mediaUrls,
          'media_type': mediaType,
        }
      ]).select();

      if (res.isNotEmpty) {
        final newPost = res.first as Map<String, dynamic>;
        state = state.copyWith(posts: [newPost, ...state.posts]);
      }

      await refresh();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> toggleLike(String postId) async {
    if (userId == null) return;

    try {
      final existingLike = await _client.from('post_likes').select().filter('post_id', 'eq', postId).filter('user_id', 'eq', userId!).maybeSingle();
      if (existingLike != null) {
        await _client.from('post_likes').delete().filter('post_id', 'eq', postId).filter('user_id', 'eq', userId!);
      } else {
        await _client.from('post_likes').insert({'post_id': postId, 'user_id': userId!});
      }
      await refresh();
    } catch (e) {}
  }

  Future<void> toggleSave(String postId) async {
    if (userId == null) return;

    try {
      final existingSave = await _client.from('post_saves').select().filter('post_id', 'eq', postId).filter('user_id', 'eq', userId!).maybeSingle();
      if (existingSave != null) {
        await _client.from('post_saves').delete().filter('post_id', 'eq', postId).filter('user_id', 'eq', userId!);
      } else {
        await _client.from('post_saves').insert({'post_id': postId, 'user_id': userId!});
      }
      await refresh();
    } catch (_) {}
  }

  // -----------------------
  // Realtime Feed Updates
  // -----------------------
  void _subscribeRealtime() {
    _channel = _client.channel('public:posts').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'posts',
      callback: (payload) {
        try {
          final newPost =
              Map<String, dynamic>.from(payload.newRecord);

          // Prepend only unique posts
          if (!state.posts.any((p) => p['id'] == newPost['id'])) {
            state = state.copyWith(
              posts: [newPost, ...state.posts],
            );
          }
        } catch (e) {
          debugPrint('Error in realtime update: $e');
        }
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
