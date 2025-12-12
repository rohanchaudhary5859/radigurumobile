import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'story_controller.dart';

class CreateStoryScreen extends ConsumerStatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  ConsumerState<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends ConsumerState<CreateStoryScreen> {
  File? _media;
  String mediaType = "image"; // image / video
  final captionCtrl = TextEditingController();

  Future<void> pickMedia() async {
    final picker = ImagePicker();

    final media = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (media != null) {
      setState(() {
        _media = File(media.path);
        mediaType = "image";
      });
    }
  }

  Future<void> uploadStory() async {
    if (_media == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select a media first")));
      return;
    }

    await ref.read(storyControllerProvider.notifier).createStory(
          file: _media!,
          mediaType: mediaType,
          caption: captionCtrl.text.trim(),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(storyControllerProvider).loading;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Story")),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          if (_media != null)
            Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black12,
              ),
              child: Image.file(_media!, fit: BoxFit.cover),
            ),

          TextButton.icon(
            onPressed: pickMedia,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text("Pick Photo"),
          ),

          TextField(
            controller: captionCtrl,
            decoration: const InputDecoration(
              label: Text("Caption (optional)"),
            ),
          ),

          const SizedBox(height: 20),

          loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: uploadStory,
                  child: const Text("Upload Story"),
                ),
        ],
      ),
    );
  }
}
