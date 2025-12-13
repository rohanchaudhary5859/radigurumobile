import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../follow/follow_controller.dart';
import 'widgets/follow_button.dart';
import '../../app_router_args.dart';

class FollowersScreen extends ConsumerStatefulWidget {
  final FollowersArgs? args;
  const FollowersScreen({super.key, this.args});

  @override
  ConsumerState<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends ConsumerState<FollowersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(followControllerProvider.notifier).loadFollowers(widget.args?.userId ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(followControllerProvider);

    final followers = state.followers;

    return Scaffold(
      appBar: AppBar(title: const Text("Followers")),
      body: state.followers.isEmpty && state.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: followers.length,
              itemBuilder: (context, index) {
                final item = followers[index];

                // Extract profile safely
                final profile = item['profiles'] ??
                    item['follower'] ??
                    {} as Map<String, dynamic>;

                final followerId =
                    profile['id'] ?? item['follower_id'] ?? "";

                final avatar = profile['avatar_url'] ?? "";
                final username = profile['username'] ?? "User";

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        avatar.isNotEmpty ? NetworkImage(avatar) : null,
                    child: avatar.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(username),
                  trailing: followerId.isNotEmpty
                      ? FollowButton(targetId: followerId)
                      : null,
                );
              },
            ),
    );
  }
}
