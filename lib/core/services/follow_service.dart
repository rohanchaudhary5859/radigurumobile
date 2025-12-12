import 'package:supabase_flutter/supabase_flutter.dart';

class FollowService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Toggle follow: if already following → unfollow, else → follow/request
  Future<String> toggleFollow({
    required String actorId,
    required String targetId,
  }) async {
    // Check if already following
    final exists = await _client
        .from('follows')
        .select()
        .eq('follower_id', actorId)
        .eq('followed_id', targetId)
        .maybeSingle();

    if (exists != null) {
      // Unfollow
      await _client
          .from('follows')
          .delete()
          .eq('follower_id', actorId)
          .eq('followed_id', targetId);

      return 'unfollowed';
    }

    // Check if target is private
    final profile = await _client
        .from('profiles')
        .select('is_private')
        .eq('id', targetId)
        .maybeSingle();

    final isPrivate = (profile?['is_private'] ?? false) == true;

    if (isPrivate) {
      // Create follow request
      await _client.from('follow_requests').insert({
        'requester_id': actorId,
        'target_id': targetId,
      });

      return 'requested';
    }

    // Direct follow
    await _client.from('follows').insert({
      'follower_id': actorId,
      'followed_id': targetId,
    });

    // Optional notification
    await _client.from('notifications').insert({
      'receiver_id': targetId,
      'type': 'follow',
      'sender_id': actorId,
      'post_id': null,
      'data': {'info': 'new_follow'}
    });

    return 'followed';
  }

  /// Accept follow request
  Future<void> acceptRequest({
    required String targetId,
    required String requesterId,
  }) async {
    await _client.from('follows').insert({
      'follower_id': requesterId,
      'followed_id': targetId,
    });

    await _client
        .from('follow_requests')
        .delete()
        .eq('requester_id', requesterId)
        .eq('target_id', targetId);

    await _client.from('notifications').insert({
      'receiver_id': requesterId,
      'type': 'follow_accepted',
      'sender_id': targetId,
      'post_id': null,
      'data': {'info': 'your_request_accepted'}
    });
  }

  /// Decline follow request
  Future<void> declineRequest({
    required String targetId,
    required String requesterId,
  }) async {
    await _client
        .from('follow_requests')
        .delete()
        .eq('requester_id', requesterId)
        .eq('target_id', targetId);
  }

  /// Check follow status
  Future<String> checkStatus({
    required String actorId,
    required String targetId,
  }) async {
    final following = await _client
        .from('follows')
        .select()
        .eq('follower_id', actorId)
        .eq('followed_id', targetId)
        .maybeSingle();

    if (following != null) return 'following';

    final requested = await _client
        .from('follow_requests')
        .select()
        .eq('requester_id', actorId)
        .eq('target_id', targetId)
        .maybeSingle();

    if (requested != null) return 'requested';

    return 'none';
  }

  /// Get followers list
  Future<List<Map<String, dynamic>>> fetchFollowers(
    String userId, {
    int limit = 100,
  }) async {
    final data = await _client
        .from('follows')
        .select('follower_id, profiles!follower_id(id, username, avatar_url)')
        .eq('followed_id', userId)
        .limit(limit);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Get following list
  Future<List<Map<String, dynamic>>> fetchFollowing(
    String userId, {
    int limit = 100,
  }) async {
    final data = await _client
        .from('follows')
        .select('followed_id, profiles!followed_id(id, username, avatar_url)')
        .eq('follower_id', userId)
        .limit(limit);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Get pending follow requests
  Future<List<Map<String, dynamic>>> fetchFollowRequests(
    String userId, {
    int limit = 100,
  }) async {
    final data = await _client
        .from('follow_requests')
        .select('requester_id, profiles!requester_id(id, username, avatar_url)')
        .eq('target_id', userId)
        .limit(limit);

    return List<Map<String, dynamic>>.from(data);
  }
}
