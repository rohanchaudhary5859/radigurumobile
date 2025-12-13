import 'package:flutter/material.dart';
import '../../app_router_args.dart';

class StoryViewer extends StatelessWidget {
  final StoryViewerArgs? args;

  const StoryViewer({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final story = args?.stories.first ?? {};
    final url = story['media_url'];
    final isVideo = (story['media_type'] == 'video');

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: isVideo
              ? const Text("Video Support Coming Soon", style: TextStyle(color: Colors.white))
              : Image.network(url),
        ),
      ),
    );
  }
}
