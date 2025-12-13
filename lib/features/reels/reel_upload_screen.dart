import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReelUploadScreen extends StatefulWidget {
  const ReelUploadScreen({super.key});

  @override
  State<ReelUploadScreen> createState() => _ReelUploadScreenState();
}

class _ReelUploadScreenState extends State<ReelUploadScreen> {
  File? _video;
  final captionCtrl = TextEditingController();
  final _client = Supabase.instance.client;
  bool loading = false;

  Future pickVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked != null) setState(() => _video = File(picked.path));
  }

  Future upload() async {
    if (_video == null) return;

    setState(() => loading = true);

    final uid_ = _client.auth.currentUser!.id;
    const String bucket = 'reels';
    final path = 'reel_$uid_${DateTime.now().millisecondsSinceEpoch}.mp4';

    await _client.storage.from(bucket).upload(path, _video!);

    final url = _client.storage.from(bucket).getPublicUrl(path);

    await _client.from('reels').insert({
      'author_id': uid_,
      'video_url': url,
      'caption': captionCtrl.text.trim(),
    });

    setState(() => loading = false);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Reel")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_video != null)
              Container(height: 300, color: Colors.black12, child: Text("Video Ready", style: TextStyle(color: Colors.white))),
            const SizedBox(height: 12),
            TextField(controller: captionCtrl, decoration: const InputDecoration(labelText: "Caption")),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(onPressed: pickVideo, child: const Text("Pick Video")),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: loading ? null : upload, child: loading ? CircularProgressIndicator() : const Text("Upload")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
