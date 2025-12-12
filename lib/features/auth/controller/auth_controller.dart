import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

class AuthController extends StateNotifier<bool> {
  final Ref ref;
  AuthController(this.ref) : super(false);

  final supabase = SupabaseService.client;

  // LOGIN
  Future<String?> login(String email, String password) async {
    try {
      state = true;
      await supabase.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } finally {
      state = false;
    }
  }

  // SIGNUP
  Future<String?> signup(String email, String password, String phone) async {
    try {
      state = true;

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        phone: phone,
      );

      if (response.user == null) {
        return "Signup failed";
      }

      return null;
    } on AuthException catch (e) {
      return e.message;
    } finally {
      state = false;
    }
  }

  // OTP VERIFY
  Future<String?> verifyOTP(String phone, String token) async {
    try {
      state = true;

      await supabase.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );

      return null;
    } on AuthException catch (e) {
      return e.message;
    } finally {
      state = false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
