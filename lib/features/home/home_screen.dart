import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/widgets/feed_post.dart';
import '../../features/create/create_post_screen.dart';
import '../../features/home/controller/feed_controller.dart';

// STORIES
import '../../features/stories/story_controller.dart';
import '../../features/stories/widgets/story_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(feedControllerProvider);

    final reachedBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (reachedBottom && !state.loading && state.hasMore) {
      ref.read(feedControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radiguru'),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(feedControllerProvider.notifier).refresh();

          // FIXED: if your story controller uses load(), change accordingly
          await ref.read(storyControllerProvider.notifier).loadStories();
        },

        child: ListView(
          controller: _scrollController,
          children: [
            const StoryBar(),
            const SizedBox(height: 10),

            // FEED POSTS
            if (feedState.posts.isEmpty && feedState.loading)
              const Padding(
                padding: EdgeInsets.only(top: 200),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    feedState.posts.length + (feedState.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= feedState.posts.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return FeedPost(post: feedState.posts[index]);
                },
              ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePostScreen(),
            ),
          );

          if (res == true) {
            await ref.read(feedControllerProvider.notifier).refresh();
            await ref.read(storyControllerProvider.notifier).loadStories();
          }
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
