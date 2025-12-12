import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/home/controller/feed_controller.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final captionCtrl = TextEditingController();
  File? _media;
  String mediaType = 'image';

  Future<void> _pick() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _media = File(picked.path);
        mediaType = 'image';
      });
    }
  }

  Future<void> _submit() async {
    final caption = captionCtrl.text.trim();

    if (_media == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please select an image")));
      return;
    }

    try {
      await ref.read(feedControllerProvider.notifier).createPost(
            caption: caption,
            mediaFile: _media,
            mediaType: mediaType,
          );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (_media != null)
            Image.file(
              _media!,
              height: 300,
              fit: BoxFit.cover,
            ),

          TextButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.photo),
            label: const Text('Pick Photo'),
          ),

          TextField(
            controller: captionCtrl,
            decoration: const InputDecoration(labelText: 'Write a caption'),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _submit,
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
