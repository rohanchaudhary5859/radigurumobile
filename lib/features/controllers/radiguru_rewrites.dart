// File: lib/features/controllers/radiguru_rewrites.dart
// This single file contains Riverpod Generator based controllers and state models
// for the Radiguru project (Option B). After adding this file, run:
//   flutter pub get
//   flutter pub run build_runner build --delete-conflicting-outputs
// then run the app.

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'radiguru_rewrites.g.dart';

// -------------------------
// STATE MODELS (immutable-ish with copyWith)
// -------------------------

class FollowState {
  final bool loading;
  final List<Map<String, dynamic>> followers;
  final List<Map<String, dynamic>> following;
  final List<Map<String, dynamic>> requests;
  final String? error;

  FollowState({
    required this.loading,
    required this.followers,
    required this.following,
    required this.requests,
    this.error,
  });

  factory FollowState.initial() => FollowState(
        loading: false,
        followers: [],
        following: [],
        requests: [],
        error: null,
      );

  FollowState copyWith({
    bool? loading,
    List<Map<String, dynamic>>? followers,
    List<Map<String, dynamic>>? following,
    List<Map<String, dynamic>>? requests,
    String? error,
  }) {
    return FollowState(
      loading: loading ?? this.loading,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      requests: requests ?? this.requests,
      error: error ?? this.error,
    );
  }
}

class UserProfileState {
  final bool loading;
  final Map<String, dynamic>? profile;
  final List<Map<String, dynamic>> posts;
  final bool hasMorePosts;
  final bool loadingPosts;
  final String? error;

  UserProfileState({
    required this.loading,
    required this.profile,
    required this.posts,
    required this.hasMorePosts,
    required this.loadingPosts,
    this.error,
  });

  factory UserProfileState.initial() => UserProfileState(
        loading: false,
        profile: null,
        posts: [],
        hasMorePosts: true,
        loadingPosts: false,
        error: null,
      );

  UserProfileState copyWith({
    bool? loading,
    Map<String, dynamic>? profile,
    List<Map<String, dynamic>>? posts,
    bool? hasMorePosts,
    bool? loadingPosts,
    String? error,
  }) {
    return UserProfileState(
      loading: loading ?? this.loading,
      profile: profile ?? this.profile,
      posts: posts ?? this.posts,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      loadingPosts: loadingPosts ?? this.loadingPosts,
      error: error ?? this.error,
    );
  }
}

class PostDetailState {
  final bool loading;
  final Map<String, dynamic>? post;
  final List<Map<String, dynamic>> comments;
  final int likesCount;
  final bool likedByMe;
  final bool savedByMe;
  final String? error;

  PostDetailState({
    required this.loading,
    required this.post,
    required this.comments,
    required this.likesCount,
    required this.likedByMe,
    required this.savedByMe,
    this.error,
  });

  factory PostDetailState.initial() => PostDetailState(
        loading: false,
        post: null,
        comments: [],
        likesCount: 0,
        likedByMe: false,
        savedByMe: false,
        error: null,
      );

  PostDetailState copyWith({
    bool? loading,
    Map<String, dynamic>? post,
    List<Map<String, dynamic>>? comments,
    int? likesCount,
    bool? likedByMe,
    bool? savedByMe,
    String? error,
  }) {
    return PostDetailState(
      loading: loading ?? this.loading,
      post: post ?? this.post,
      comments: comments ?? this.comments,
      likesCount: likesCount ?? this.likesCount,
      likedByMe: likedByMe ?? this.likedByMe,
      savedByMe: savedByMe ?? this.savedByMe,
      error: error ?? this.error,
    );
  }
}

class CommentState {
  final bool loading;
  final List<Map<String, dynamic>> comments;
  final String? error;

  CommentState({required this.loading, required this.comments, this.error});

  factory CommentState.initial() => CommentState(loading: false, comments: [], error: null);

  CommentState copyWith({bool? loading, List<Map<String, dynamic>>? comments, String? error}) {
    return CommentState(loading: loading ?? this.loading, comments: comments ?? this.comments, error: error ?? this.error);
  }
}

class MessageState {
  final bool loading;
  final List<Map<String, dynamic>> messages;
  final String? error;

  MessageState({required this.loading, required this.messages, this.error});

  factory MessageState.initial() => MessageState(loading: false, messages: [], error: null);

  MessageState copyWith({bool? loading, List<Map<String, dynamic>>? messages, String? error}) {
    return MessageState(loading: loading ?? this.loading, messages: messages ?? this.messages, error: error ?? this.error);
  }
}

class SettingsState {
  final bool loading;
  final Map<String, dynamic>? profile;
  final String? error;

  SettingsState({required this.loading, required this.profile, this.error});

  factory SettingsState.initial() => SettingsState(loading: false, profile: null, error: null);

  SettingsState copyWith({bool? loading, Map<String, dynamic>? profile, String? error}) {
    return SettingsState(loading: loading ?? this.loading, profile: profile ?? this.profile, error: error ?? this.error);
  }
}

class AuthState {
  final bool loading;
  final bool loggedIn;
  final String? error;

  AuthState({required this.loading, required this.loggedIn, this.error});

  factory AuthState.initial() => AuthState(loading: false, loggedIn: false, error: null);

  AuthState copyWith({bool? loading, bool? loggedIn, String? error}) {
    return AuthState(loading: loading ?? this.loading, loggedIn: loggedIn ?? this.loggedIn, error: error ?? this.error);
  }
}

// -------------------------
// CONTROLLERS (Riverpod generator)
// -------------------------

@riverpod
class FollowController extends _$FollowController {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  FollowState build() => FollowState.initial();

  Future<void> fetchFollowers(String userId) async {
    state = state.copyWith(loading: true);
    try {
      final res = await _client.from('follows').select('follower:profiles(*), following:profiles(*)').filter('follower_id', 'eq', userId);
      final followers = <Map<String, dynamic>>[];
      final following = <Map<String, dynamic>>[];
      for (final item in res) {
        if (item['follower'] != null) followers.add(Map<String, dynamic>.from(item['follower']));
        if (item['following'] != null) following.add(Map<String, dynamic>.from(item['following']));
      }
      state = state.copyWith(followers: followers, following: following, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> fetchFollowing(String userId) async {
    state = state.copyWith(loading: true);
    try {
      final res = await _client.from('follows').select('followed:profiles(*)').filter('follower_id', 'eq', userId);
      final list = <Map<String, dynamic>>[];
      for (final item in res) {
        if (item['followed'] != null) list.add(Map<String, dynamic>.from(item['followed']));
      }
      state = state.copyWith(following: list, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> sendFollowRequest(String requesterId, String targetId) async {
    state = state.copyWith(loading: true);
    try {
      await _client.from('follow_requests').insert({'requester_id': requesterId, 'target_id': targetId});
      // refresh requests
      await fetchRequests(targetId);
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> fetchRequests(String userId) async {
    state = state.copyWith(loading: true);
    try {
      final res = await _client.from('follow_requests').select('requester:profiles(*)').filter('target_id', 'eq', userId);
      final list = <Map<String, dynamic>>[];
      for (final item in res) {
        if (item['requester'] != null) list.add(Map<String, dynamic>.from(item['requester']));
      }
      state = state.copyWith(requests: list, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

@riverpod
class UserProfileController extends _$UserProfileController {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  UserProfileState build() => UserProfileState.initial();

  Future<void> loadProfile(String userId) async {
    state = state.copyWith(loading: true);
    try {
      final res = await _client.from('profiles').select().filter('id', 'eq', userId).maybeSingle();
      final profile = res;
      state = state.copyWith(profile: profile, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> loadPosts(String userId, {int limit = 10, String? fromCursor}) async {
    if (!state.hasMorePosts || state.loadingPosts) return;
    state = state.copyWith(loadingPosts: true);
    try {
      var query = _client.from('posts').select().filter('user_id', 'eq', userId).order('created_at', ascending: false);
      dynamic data;
      if (fromCursor != null) {
        data = await _client.from('posts').select().filter('user_id', 'eq', userId).lt('created_at', fromCursor).order('created_at', ascending: false).limit(limit);
      } else {
        data = await query.limit(limit);
      }
      final list = List<Map<String, dynamic>>.from(data);
      final all = [...state.posts, ...list];
      state = state.copyWith(posts: all, hasMorePosts: list.length == limit, loadingPosts: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loadingPosts: false);
    }
  }
}

@riverpod
class PostDetailController extends _$PostDetailController {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  PostDetailState build() => PostDetailState.initial();

  Future<void> loadPost(String postId) async {
    state = state.copyWith(loading: true);
    try {
      final res = await _client.from('posts').select().filter('id', 'eq', postId).maybeSingle();
      final post = res;
      // fetch likes, comments counts
      final likesRes = await _client.from('post_likes').select('id').filter('post_id', 'eq', postId);
      // Note: Postgrest API shape may differ; adapt as needed
      final likesCount = likesRes.length;

      final commentsRes = await _client.from('post_comments').select().filter('post_id', 'eq', postId).order('created_at', ascending: true);
      final comments = List<Map<String, dynamic>>.from(commentsRes);

      state = state.copyWith(post: post, likesCount: likesCount, comments: comments, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> toggleLike(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    state = state.copyWith(loading: true);
    try {
      // check if liked
      final res = await _client.from('post_likes').select().filter('post_id', 'eq', postId).filter('user_id', 'eq', userId).maybeSingle();
      if (res != null) {
        await _client.from('post_likes').delete().filter('post_id', 'eq', postId).filter('user_id', 'eq', userId);
        state = state.copyWith(likedByMe: false, likesCount: state.likesCount - 1, loading: false);
      } else {
        await _client.from('post_likes').insert({'post_id': postId, 'user_id': userId});
        state = state.copyWith(likedByMe: true, likesCount: state.likesCount + 1, loading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> toggleSave(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    state = state.copyWith(loading: true);
    try {
      final res = await _client.from('post_saves').select().filter('post_id', 'eq', postId).filter('user_id', 'eq', userId).maybeSingle();
      if (res != null) {
        await _client.from('post_saves').delete().filter('post_id', 'eq', postId).filter('user_id', 'eq', userId);
        state = state.copyWith(savedByMe: false, loading: false);
      } else {
        await _client.from('post_saves').insert({'post_id': postId, 'user_id': userId});
        state = state.copyWith(savedByMe: true, loading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

@riverpod
class CommentController extends _$CommentController {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  CommentState build() => CommentState.initial();

  Future<void> loadComments(String postId) async {
    state = state.copyWith(loading: true);
    try {
      final res = await _client.from('post_comments').select().filter('post_id', 'eq', postId).order('created_at', ascending: true);
      final list = List<Map<String, dynamic>>.from(res);
      state = state.copyWith(comments: list, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> addComment(String postId, String text) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    state = state.copyWith(loading: true);
    try {
      await _client.from('post_comments').insert({'post_id': postId, 'user_id': userId, 'content': text});
      await loadComments(postId);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

@riverpod
class MessageController extends _$MessageController {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _channel;

  @override
  MessageState build() => MessageState.initial();

  Future<void> fetchMessages(String conversationId) async {
    state = state.copyWith(loading: true);
    try {
      final res = await _client.from('messages').select().filter('conversation_id', 'eq', conversationId).order('created_at', ascending: true);
      final list = List<Map<String, dynamic>>.from(res);
      state = state.copyWith(messages: list, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _client.from('messages').insert({'conversation_id': conversationId, 'sender_id': userId, 'content': text});
      // fetch again or rely on realtime
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void subscribeToConversation(String conversationId) {
    _channel?.unsubscribe();
    _channel = _client.channel('public:messages').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public', 
      table: 'messages',
      callback: (payload) {
        // handle realtime message
        // when a message arrives, append it to messages
        try {
          final record = Map<String, dynamic>.from(payload.newRecord ?? {});
          state = state.copyWith(messages: [...state.messages, record]);
        } catch (_) {}
      },
    ).subscribe();
  }

  void disposeChannel() {
    _channel?.unsubscribe();
    _channel = null;
  }
}

@riverpod
class SettingsController extends _$SettingsController {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  SettingsState build() => SettingsState.initial();

  Future<void> loadMyProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    state = state.copyWith(loading: true);
    try {
      final res = await _client.from('profiles').select().filter('id', 'eq', userId).maybeSingle();
      state = state.copyWith(profile: res, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> updateProfileField(String field, dynamic value) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    state = state.copyWith(loading: true);
    try {
      await _client.from('profiles').update({field: value}).filter('id', 'eq', userId);
      await loadMyProfile();
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }
}

@riverpod
class AuthController extends _$AuthController {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  AuthState build() => AuthState.initial();

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(loading: true);
    try {
      final res = await _client.auth.signInWithPassword(email: email, password: password);
      final user = res.user;
      state = state.copyWith(loading: false, loggedIn: user != null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> signUpWithEmail(String email, String password, Map<String, dynamic> extra) async {
    state = state.copyWith(loading: true);
    try {
      final res = await _client.auth.signUp(email: email, password: password, data: extra);
      state = state.copyWith(loading: false, loggedIn: res.user != null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    state = state.copyWith(loggedIn: false);
  }
}
