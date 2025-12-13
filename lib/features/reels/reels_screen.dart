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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reels',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: state.reels.isEmpty && !state.loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_outlined,
                    size: 64,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No reels yet',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              onPageChanged: (i) {
                if (i >= state.reels.length - 2) {
                  ref.read(reelControllerProvider.notifier).loadReels();
                }
              },
              itemCount: state.reels.length + (state.loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.reels.length && state.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                
                final reel = state.reels[index];
                return Stack(
                  fit: StackFit.expand,
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
