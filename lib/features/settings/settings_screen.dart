import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/settings_tile.dart';
import 'controller/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SettingsTile(
                  title: "Private Account",
                  value: state.privateAccount,
                  onChanged: (v) {
                    ref.read(settingsControllerProvider.notifier).updateSetting('private_account', v);
                  },
                ),
                SettingsTile(
                  title: "Notifications Enabled",
                  value: state.notificationsEnabled,
                  onChanged: (v) {
                    ref.read(settingsControllerProvider.notifier).updateSetting('notifications_enabled', v);
                  },
                ),
                SettingsTile(
                  title: "Dark Mode",
                  value: state.darkMode,
                  onChanged: (v) {
                    ref.read(settingsControllerProvider.notifier).updateSetting('dark_mode', v);
                  },
                ),
                SettingsTile(
                  title: "Professional (Doctor) Account",
                  value: state.isDoctor,
                  onChanged: (v) {
                    ref.read(settingsControllerProvider.notifier).updateSetting('role', v ? 'doctor' : 'patient');
                  },
                ),

                const Divider(),

                ListTile(
                  title: const Text("Edit Profile"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.pushNamed(context, "/edit-profile"),
                ),

                const Divider(),

                ListTile(
                  title: const Text("Logout", style: TextStyle(color: Colors.red)),
                  trailing: const Icon(Icons.logout, color: Colors.red),
                  onTap: () async {
                    await ref.read(settingsControllerProvider.notifier).logout();
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                ),
              ],
            ),
    );
  }
}
