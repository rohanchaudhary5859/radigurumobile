import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileState {
  final bool loading;
  final Map<String, dynamic>? profile;
  final List<Map<String, dynamic>> posts;
  final bool loadingPosts;
  final bool hasMorePosts;

  UserProfileState({
    this.loading = false,
    this.profile,
    this.posts = const [],
    this.loadingPosts = false,
    this.hasMorePosts = true,
  });

  UserProfileState copyWith({
    bool? loading,
    Map<String, dynamic>? profile,
    List<Map<String, dynamic>>? posts,
    bool? loadingPosts,
    bool? hasMorePosts,
  }) {
    return UserProfileState(
      loading: loading ?? this.loading,
      profile: profile ?? this.profile,
      posts: posts ?? this.posts,
      loadingPosts: loadingPosts ?? this.loadingPosts,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
    );
  }
}

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, UserProfileState>(
  (ref) => UserProfileController(),
);

class UserProfileController extends StateNotifier<UserProfileState> {
  UserProfileController() : super(UserProfileState());

  final _client = Supabase.instance.client;
  int _page = 0;
  final int limit = 12;

  Future<void> loadProfile(String userId) async {
    state = state.copyWith(loading: true);

    final profile = await _client
        .from('profiles')
        .select()
        .filter('id', 'eq', userId)
        .single();

    state = state.copyWith(loading: false, profile: profile);
    await loadPosts(userId, reset: true);
  }

  Future<void> loadPosts(String userId, {bool reset = false}) async {
    if (reset) {
      _page = 0;
      state = state.copyWith(posts: [], hasMorePosts: true);
    }

    if (!state.hasMorePosts || state.loadingPosts) return;

    state = state.copyWith(loadingPosts: true);

    final offset = _page * limit;

    final res = await _client
        .from('posts')
        .select('id, media_urls, caption, author_id')
        .filter('author_id', 'eq', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final list = (res as List).map((e) => Map<String, dynamic>.from(e)).toList();

    state = state.copyWith(
      posts: [...state.posts, ...list],
      loadingPosts: false,
      hasMorePosts: list.length == limit,
    );

    if (list.length == limit) _page++;
  }
}
