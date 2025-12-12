import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/services/storage_service.dart';

final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>(
  (ref) => ProfileController(ref),
);

class ProfileState {
  final bool loading;
  final Map<String, dynamic>? profile;
  final String? error;

  ProfileState({this.loading = false, this.profile, this.error});

  ProfileState copyWith({bool? loading, Map<String, dynamic>? profile, String? error}) {
    return ProfileState(
      loading: loading ?? this.loading,
      profile: profile ?? this.profile,
      error: error ?? this.error,
    );
  }
}

class ProfileController extends StateNotifier<ProfileState> {
  final Ref ref;
  final ProfileService _service = ProfileService();
  final StorageService _storage = StorageService();
  final SupabaseClient _client = Supabase.instance.client;

  ProfileController(this.ref) : super(ProfileState());

  String? get userId => _client.auth.currentUser?.id;

  Future<void> loadProfile({String? id}) async {
    final uid = id ?? userId;
    if (uid == null) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await _service.getProfile(uid);
      state = state.copyWith(profile: data, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (userId == null) throw Exception('Not authenticated');
    state = state.copyWith(loading: true, error: null);
    try {
      updates['id'] = userId;
      await _service.upsertProfile(updates);
      await loadProfile();
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> uploadAvatar(File file) async {
    if (userId == null) throw Exception('Not authenticated');

    state = state.copyWith(loading: true, error: null);
    try {
      final path = 'avatars/$userId${_extFromPath(file.path)}';
      final url = await _storage.uploadFile(bucket: 'avatars', file: file, path: path);

      await _service.upsertProfile({'id': userId, 'avatar_url': url});
      await loadProfile();
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  String _extFromPath(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return '.jpg';
    return path.substring(idx);
  }
}
