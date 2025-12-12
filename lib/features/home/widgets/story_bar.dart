import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../stories/story_controller.dart';
import '../../stories/widgets/story_tile.dart';
import '../../stories/story_viewer.dart';

class StoryBar extends ConsumerWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storyControllerProvider);

    if (state.loading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.stories.isEmpty) {
      return const SizedBox(height: 0);
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        scrollDirection: Axis.horizontal,
        itemCount: state.stories.length,
        itemBuilder: (context, i) {
          final s = state.stories[i];
          final profile = s['profiles'];

          return StoryTile(
            avatar: profile?['avatar_url'] ?? "",
            username: profile?['username'] ?? "user",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoryViewer(story: s),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
