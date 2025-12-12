import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final postDetailControllerProvider =
    StateNotifierProvider<PostDetailController, PostDetailState>(
  (ref) => PostDetailController(),
);

class PostDetailState {
  final bool loading;
  final Map<String, dynamic>? post;
  final int likesCount;
  final bool likedByMe;
  final bool savedByMe;
  final List<Map<String, dynamic>> comments;

  PostDetailState({
    this.loading = false,
    this.post,
    this.likesCount = 0,
    this.likedByMe = false,
    this.savedByMe = false,
    this.comments = const [],
  });

  PostDetailState copyWith({
    bool? loading,
    Map<String, dynamic>? post,
    int? likesCount,
    bool? likedByMe,
    bool? savedByMe,
    List<Map<String, dynamic>>? comments,
  }) {
    return PostDetailState(
      loading: loading ?? this.loading,
      post: post ?? this.post,
      likesCount: likesCount ?? this.likesCount,
      likedByMe: likedByMe ?? this.likedByMe,
      savedByMe: savedByMe ?? this.savedByMe,
      comments: comments ?? this.comments,
    );
  }
}

class PostDetailController extends StateNotifier<PostDetailState> {
  PostDetailController() : super(PostDetailState());

  final SupabaseClient _client = Supabase.instance.client;

  String? get userId => _client.auth.currentUser?.id;

  Future<void> loadPost(String postId) async {
    state = state.copyWith(loading: true);

    try {
      // -----------------------------
      // 1. Fetch Post
      // -----------------------------
      final postRes = await _client
          .from('posts')
          .select(
              'id, caption, media_urls, media_type, created_at, author_id, profiles(username, avatar_url)')
          .eq('id', postId)
          .maybeSingle();

      final post = postRes as Map<String, dynamic>?;

      // -----------------------------
      // 2. Get Likes Count
      // -----------------------------
      final likesRes = await _client
          .from('post_likes')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('post_id', postId);

      final likesCount = likesRes.count ?? 0;

      // -----------------------------
      // 3. Check if I Liked
      // -----------------------------
      bool liked = false;
      if (userId != null) {
        final likeCheck = await _client
            .from('post_likes')
            .select()
            .eq('post_id', postId)
            .eq('user_id', userId)
            .maybeSingle();

        liked = likeCheck != null;
      }

      // -----------------------------
      // 4. Check if I Saved
      // -----------------------------
      bool saved = false;
      if (userId != null) {
        final saveCheck = await _client
            .from('post_saves')
            .select()
            .eq('post_id', postId)
            .eq('user_id', userId)
            .maybeSingle();

        saved = saveCheck != null;
      }

      // -----------------------------
      // 5. Fetch Comments
      // -----------------------------
      final commentsRes = await _client
          .from('comments')
          .select(
              'id, content, created_at, author_id, profiles(id, username, avatar_url)')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      final comments = (commentsRes as List<dynamic>? ?? [])
          .map((e) =>
              Map<String, dynamic>.from(e as Map<String, dynamic>))
          .toList();

      // -----------------------------
      // Update State
      // -----------------------------
      state = state.copyWith(
        loading: false,
        post: post,
        likesCount: likesCount,
        likedByMe: liked,
        savedByMe: saved,
        comments: comments,
      );
    } catch (e) {
      state = state.copyWith(loading: false);
    }
  }

  // ------------------------------------------------------
  // LIKE TOGGLE
  // ------------------------------------------------------
  Future<void> toggleLike(String postId) async {
    if (userId == null) return;

    final exists = await _client
        .from('post_likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (exists != null) {
      await _client
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
    } else {
      await _client
          .from('post_likes')
          .insert({'post_id': postId, 'user_id': userId});
    }

    await loadPost(postId);
  }

  // ------------------------------------------------------
  // SAVE TOGGLE
  // ------------------------------------------------------
  Future<void> toggleSave(String postId) async {
    if (userId == null) return;

    final exists = await _client
        .from('post_saves')
        .select()
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (exists != null) {
      await _client
          .from('post_saves')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
    } else {
      await _client
          .from('post_saves')
          .insert({'post_id': postId, 'user_id': userId});
    }

    await loadPost(postId);
  }

  // ------------------------------------------------------
  // ADD COMMENT
  // ------------------------------------------------------
  Future<void> addComment(String postId, String content) async {
    if (userId == null) return;

    await _client.from('comments').insert({
      'post_id': postId,
      'author_id': userId,
      'content': content,
    });

    await loadPost(postId);
  }
}
