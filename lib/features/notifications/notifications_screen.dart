import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notifications_controller.dart';
import 'widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),

      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, i) {
                final n = state.notifications[i];
                return NotificationTile(
                  data: n,
                  onTap: () {
                    ref.read(notificationControllerProvider.notifier).markRead(n['id']);
                  },
                );
              },
            ),
    );
  }
}
