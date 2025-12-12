import 'package:flutter/material.dart';

class StoryViewer extends StatelessWidget {
  final Map story;

  const StoryViewer({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
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
