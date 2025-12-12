import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/profile/controller/profile_controller.dart';

final currentProfileProvider = Provider<ProfileState?>((ref) {
  return ref.watch(profileControllerProvider);
});
