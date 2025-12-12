import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/env.dart';

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: SUPABASE_URL,
      anonKey: SUPABASE_ANON_KEY,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
