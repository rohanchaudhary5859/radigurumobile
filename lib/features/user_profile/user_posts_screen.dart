import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'controller/user_profile_controller.dart';
import 'widgets/user_post_tile.dart';

class UserPostsScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserPostsScreen({super.key, required this.userId});

  @override
  ConsumerState<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends ConsumerState<UserPostsScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.read(userProfileControllerProvider.notifier).loadPosts(widget.userId, reset: true);

    _scroll.addListener(() {
      final state = ref.read(userProfileControllerProvider);
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 &&
          !state.loadingPosts &&
          state.hasMorePosts) {
        ref.read(userProfileControllerProvider.notifier).loadPosts(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Posts")),
      body: GridView.builder(
        controller: _scroll,
        itemCount: state.posts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (_, i) {
          final p = state.posts[i];
          return UserPostTile(post: p);
        },
      ),
    );
  }
}
