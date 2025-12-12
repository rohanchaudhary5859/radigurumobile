import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/widgets/avatar.dart';
import '../../features/profile/controller/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final usernameCtrl = TextEditingController();
  final fullNameCtrl = TextEditingController();
  final specializationCtrl = TextEditingController();
  final hospitalCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  bool isDoctor = false;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).profile ?? {};
    usernameCtrl.text = profile['username'] ?? '';
    fullNameCtrl.text = profile['full_name'] ?? '';
    specializationCtrl.text = profile['specialization'] ?? '';
    hospitalCtrl.text = profile['hospital_name'] ?? '';
    bioCtrl.text = profile['bio'] ?? '';
    isDoctor = (profile['role'] ?? 'patient') == 'doctor';
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    final controller = ref.read(profileControllerProvider.notifier);
    try {
      if (_pickedImage != null) {
        await controller.uploadAvatar(_pickedImage!);
      }
      await controller.updateProfile({
        'username': usernameCtrl.text.trim(),
        'full_name': fullNameCtrl.text.trim(),
        'specialization': specializationCtrl.text.trim(),
        'hospital_name': hospitalCtrl.text.trim(),
        'bio': bioCtrl.text.trim(),
        'role': isDoctor ? 'doctor' : 'patient',
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final avatarUrl = state.profile?['avatar_url'] as String?;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      Avatar(url: _pickedImage == null ? avatarUrl : _pickedImage!.path, size: 96, onTap: _pickAvatar),
                      TextButton(onPressed: _pickAvatar, child: const Text('Change Avatar')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username')),
                TextField(controller: fullNameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
                TextField(controller: specializationCtrl, decoration: const InputDecoration(labelText: 'Specialization')),
                TextField(controller: hospitalCtrl, decoration: const InputDecoration(labelText: 'Hospital / Clinic')),
                TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Bio'), maxLines: 3),
                SwitchListTile(
                    title: const Text('I am a doctor'),
                    value: isDoctor,
                    onChanged: (v) => setState(() => isDoctor = v)),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
    );
  }
}
