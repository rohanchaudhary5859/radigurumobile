import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reel_controller.dart';
import 'widgets/reel_player.dart';
import 'widgets/reel_overlay.dart';

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reelControllerProvider);

    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        onPageChanged: (i) {
          if (i >= state.reels.length - 2) {
            ref.read(reelControllerProvider.notifier).loadReels();
          }
        },
        itemCount: state.reels.length,
        itemBuilder: (context, index) {
          final reel = state.reels[index];
          return Stack(
            children: [
              ReelPlayer(videoUrl: reel['video_url']),
              ReelOverlay(
                reel: reel,
                onLike: () {
                  ref.read(reelControllerProvider.notifier).likeReel(reel['id']);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
