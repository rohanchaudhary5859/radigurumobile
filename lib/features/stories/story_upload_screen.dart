import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'story_controller.dart';

class StoryUploadScreen extends ConsumerStatefulWidget {
  const StoryUploadScreen({super.key});

  @override
  ConsumerState<StoryUploadScreen> createState() => _StoryUploadScreenState();
}

class _StoryUploadScreenState extends ConsumerState<StoryUploadScreen> {
  File? _media;

  Future pick() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _media = File(img.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storyControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Story")),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                if (_media != null)
                  Image.file(_media!, height: 300, fit: BoxFit.cover),
                TextButton(onPressed: pick, child: const Text("Pick Media")),
                ElevatedButton(
                  onPressed: () async {
                    if (_media != null) {
                      await ref.read(storyControllerProvider.notifier).uploadStory(_media!);
                      if (mounted) Navigator.pop(context, true);
                    }
                  },
                  child: const Text("Upload Story"),
                )
              ],
            ),
    );
  }
}
