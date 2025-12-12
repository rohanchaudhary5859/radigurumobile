import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsState {
  final bool loading;
  final bool darkMode;
  final bool privateAccount;
  final bool notificationsEnabled;
  final bool isDoctor;

  SettingsState({
    this.loading = false,
    this.darkMode = false,
    this.privateAccount = false,
    this.notificationsEnabled = true,
    this.isDoctor = false,
  });

  SettingsState copyWith({
    bool? loading,
    bool? darkMode,
    bool? privateAccount,
    bool? notificationsEnabled,
    bool? isDoctor,
  }) {
    return SettingsState(
      loading: loading ?? this.loading,
      darkMode: darkMode ?? this.darkMode,
      privateAccount: privateAccount ?? this.privateAccount,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isDoctor: isDoctor ?? this.isDoctor,
    );
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>(
  (ref) => SettingsController(),
);

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(SettingsState()) {
    loadSettings();
  }

  final SupabaseClient _client = Supabase.instance.client;

  String? get userId => _client.auth.currentUser?.id;

  Future<void> loadSettings() async {
    if (userId == null) return;

    state = state.copyWith(loading: true);

    try {
      // FIX: .single() → .maybeSingle()
      final res = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final profile = res as Map<String, dynamic>?;

      state = state.copyWith(
        loading: false,
        privateAccount: profile?['private_account'] ?? false,
        notificationsEnabled: profile?['notifications_enabled'] ?? true,
        isDoctor: (profile?['role'] == 'doctor'),
        darkMode: profile?['dark_mode'] ?? false,
      );
    } catch (e) {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> updateSetting(String field, dynamic value) async {
    if (userId == null) return;
    state = state.copyWith(loading: true);

    try {
      await _client.from('profiles').update({field: value}).eq('id', userId);
      await loadSettings();
    } catch (e) {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
