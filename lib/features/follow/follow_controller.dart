import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/follow_service.dart';

final followControllerProvider =
    StateNotifierProvider<FollowController, FollowState>(
  (ref) => FollowController(ref),
);

class FollowState {
  final bool loading;
  final String status; // following / requested / none
  final List<Map<String, dynamic>> followers;
  final List<Map<String, dynamic>> following;
  final List<Map<String, dynamic>> requests;

  const FollowState({
    this.loading = false,
    this.status = 'none',
    this.followers = const [],
    this.following = const [],
    this.requests = const [],
  });

  FollowState copyWith({
    bool? loading,
    String? status,
    List<Map<String, dynamic>>? followers,
    List<Map<String, dynamic>>? following,
    List<Map<String, dynamic>>? requests,
  }) {
    return FollowState(
      loading: loading ?? this.loading,
      status: status ?? this.status,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      requests: requests ?? this.requests,
    );
  }
}

class FollowController extends StateNotifier<FollowState> {
  final Ref ref;
  final FollowService _service = FollowService();
  final SupabaseClient _client = Supabase.instance.client;

  FollowController(this.ref) : super(const FollowState());

  String? get userId => _client.auth.currentUser?.id;

  /// Check current user → target relationship
  Future<void> checkStatus(String targetId) async {
    if (userId == null) return;
    try {
      final s =
          await _service.checkStatus(actorId: userId!, targetId: targetId);
      state = state.copyWith(status: s);
    } catch (_) {}
  }

  /// Follow / Unfollow / Cancel request
  Future<String?> toggleFollow(String targetId) async {
    if (userId == null) return null;
    state = state.copyWith(loading: true);

    try {
      final result =
          await _service.toggleFollow(actorId: userId!, targetId: targetId);

      // Refresh ONLY the needed data
      await checkStatus(targetId);

      state = state.copyWith(loading: false);
      return result;
    } catch (e) {
      state = state.copyWith(loading: false);
      return null;
    }
  }

  Future<void> loadFollowers(String targetId) async {
    try {
      final list = await _service.fetchFollowers(targetId);
      state = state.copyWith(followers: list);
    } catch (_) {}
  }

  Future<void> loadFollowing(String userIdArg) async {
    try {
      final list = await _service.fetchFollowing(userIdArg);
      state = state.copyWith(following: list);
    } catch (_) {}
  }

  Future<void> loadRequests() async {
    if (userId == null) return;
    try {
      final list = await _service.fetchFollowRequests(userId!);
      state = state.copyWith(requests: list);
    } catch (_) {}
  }

  Future<void> acceptRequest(String requesterId) async {
    if (userId == null) return;
    state = state.copyWith(loading: true);
    await _service.acceptRequest(
        targetId: userId!, requesterId: requesterId);
    await loadRequests();
    state = state.copyWith(loading: false);
  }

  Future<void> declineRequest(String requesterId) async {
    if (userId == null) return;
    state = state.copyWith(loading: true);
    await _service.declineRequest(
        targetId: userId!, requesterId: requesterId);
    await loadRequests();
    state = state.copyWith(loading: false);
  }
}
