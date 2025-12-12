import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../follow_controller.dart';

class FollowButton extends ConsumerWidget {
  final String targetId;
  final double width;
  final double height;

  const FollowButton({super.key, required this.targetId, this.width = 110, this.height = 36});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(followControllerProvider);
    final controller = ref.read(followControllerProvider.notifier);

    // If the controller hasn't checked status for this target, call it
    if (state.status == 'none') {
      // run check once (non-blocking)
      controller.checkStatus(targetId);
    }

    Widget child;
    final status = state.status;

    if (state.loading) {
      child = const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
    } else if (status == 'following') {
      child = const Text('Following', style: TextStyle(color: Colors.black));
    } else if (status == 'requested') {
      child = const Text('Requested', style: TextStyle(color: Colors.black));
    } else {
      child = const Text('Follow', style: TextStyle(color: Colors.white));
    }

    final isFollowing = status == 'following';

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Colors.white : Colors.blue,
          side: isFollowing ? const BorderSide(color: Colors.grey) : null,
        ),
        onPressed: () async {
          await controller.toggleFollow(targetId);
          // Optionally show snackbar
          final res = ref.read(followControllerProvider.notifier);
        },
        child: child,
      ),
    );
  }
}
