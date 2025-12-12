import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/controller/auth_controller.dart';

final authProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(ref),
);
