import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// FIXED IMPORTS  
import '../follow/widgets/follow_button.dart';
import '../follow/followers_screen.dart';
import '../follow/following_screen.dart';

// These must point to your generated Riverpod controllers  
import '../follow/follow_controller.dart';
import 'controller/user_profile_controller.dart';

import 'user_posts_screen.dart';
import '../../app_router_args.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final UserProfileArgs? args;

  const UserProfileScreen({super.key, this.args});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user profile
    ref.read(userProfileControllerProvider.notifier).loadProfile(widget.args?.userId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileControllerProvider);

    if (state.loading || state.profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profile = state.profile!;
    final uid = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(profile['username'] ?? "Profile"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // AVATAR
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(profile['avatar_url'] ?? ""),
            ),
          ),

          const SizedBox(height: 10),

          // NAME
          Center(
            child: Text(
              profile['full_name'] ?? profile['username'] ?? "",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 6),

          // SPECIALIZATION
          Center(
            child: Text(
              profile['specialization'] ?? "",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 16),

          // FOLLOW BUTTON (NOT OWN PROFILE)
          if (profile['id'] != uid)
            Center(
              child: FollowButton(targetId: profile['id']),
            ),

          const SizedBox(height: 20),

          // STATS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // POSTS COUNT
              Column(
                children: [
                  Text(
                    "${state.posts.length}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text("Posts"),
                ],
              ),

              // FOLLOWERS COUNT
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FollowersScreen(args: FollowersArgs(userId: profile['id'])),
                    ),
                  );
                },
                child: Column(
                  children: [
                    FutureBuilder(
                      future: ref
                          .read(followControllerProvider.notifier)
                          .loadFollowers(profile['id']),
                      builder: (context, snapshot) {
                        final count = ref.read(followControllerProvider).followers.length;
                        return Text(
                          "$count",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    const Text("Followers"),
                  ],
                ),
              ),

              // FOLLOWING COUNT
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FollowingScreen(args: FollowingArgs(userId: profile['id'])),
                    ),
                  );
                },
                child: Column(
                  children: [
                    FutureBuilder(
                      future: ref
                          .read(followControllerProvider.notifier)
                          .loadFollowing(profile['id']),
                      builder: (context, snapshot) {
                        final count = ref.read(followControllerProvider).following.length;
                        return Text(
                          "$count",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    const Text("Following"),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // POSTS GRID
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.posts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemBuilder: (_, i) {
              final post = state.posts[i];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserPostsScreen(args: UserPostsArgs(userId: profile['id'])),
                    ),
                  );
                },
                child: Image.network(
                  (post['media_urls'] as List).first,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
