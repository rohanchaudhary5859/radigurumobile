import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../follow/follow_controller.dart';
import 'widgets/follow_button.dart';
import '../../app_router_args.dart';

class FollowingScreen extends ConsumerStatefulWidget {
  final FollowingArgs? args;
  const FollowingScreen({super.key, this.args});

  @override
  ConsumerState<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends ConsumerState<FollowingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(followControllerProvider.notifier).loadFollowing(widget.args?.userId ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(followControllerProvider);
    final following = state.following;

    return Scaffold(
      appBar: AppBar(title: const Text("Following")),
      body: following.isEmpty && state.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: following.length,
              itemBuilder: (context, index) {
                final item = following[index];

                // Supabase join output can be:
                // followed: profiles(*)
                // OR profiles(*)
                // OR followed_id
                final profile = item['profiles'] ??
                    item['followed'] ??
                    {} as Map<String, dynamic>;

                final followedId =
                    profile['id'] ?? item['followed_id'] ?? "";

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
                  trailing: followedId.isNotEmpty
                      ? FollowButton(targetId: followedId)
                      : null,
                );
              },
            ),
    );
  }
}
