import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReelState {
  final bool loading;
  final List<Map<String, dynamic>> reels;
  final bool hasMore;

  ReelState({
    this.loading = false,
    this.reels = const [],
    this.hasMore = true,
  });

  ReelState copyWith({
    bool? loading,
    List<Map<String, dynamic>>? reels,
    bool? hasMore,
  }) {
    return ReelState(
      loading: loading ?? this.loading,
      reels: reels ?? this.reels,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

final reelControllerProvider =
    StateNotifierProvider<ReelController, ReelState>(
  (ref) => ReelController(),
);

class ReelController extends StateNotifier<ReelState> {
  ReelController() : super(ReelState()) {
    loadReels(reset: true);
  }

  final _client = Supabase.instance.client;
  int _page = 0;
  final int limit = 10;

  Future<void> loadReels({bool reset = false}) async {
    if (reset) {
      _page = 0;
      state = state.copyWith(reels: [], hasMore: true);
    }

    if (!state.hasMore || state.loading) return;

    state = state.copyWith(loading: true);

    final offset = _page * limit;

    final res = await _client
        .from('reels')
        .select('''
          id,
          video_url,
          caption,
          likes,
          author_id,
          profiles(username, avatar_url)
        ''')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final data = (res as List).map((e) => Map<String, dynamic>.from(e)).toList();

    final newList = [...state.reels, ...data];
    final more = data.length == limit;

    state = state.copyWith(
      reels: newList,
      loading: false,
      hasMore: more,
    );

    if (more) _page++;
  }

  Future<void> likeReel(String reelId) async {
    await _client.rpc('like_reel', params: {'reel_id': reelId});
  }
}
