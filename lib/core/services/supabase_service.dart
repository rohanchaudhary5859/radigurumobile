import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static SupabaseService get instance => _instance;

  late final SupabaseClient _client;
  late final GoTrueClient _auth;

  SupabaseService._internal();

  SupabaseClient get client => _client;
  GoTrueClient get auth => _auth;

  static Future<void> initialize() async {
    try {
      // Load environment variables
      await dotenv.load(fileName: ".env");

      final supabaseUrl = dotenv.env['supabaseUrl'];
      final supabaseAnonKey = dotenv.env['supabaseAnonKey'];

      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception('Missing Supabase URL or Anon Key in environment variables');
      }

      // Initialize Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );

      _instance._client = Supabase.instance.client;
      _instance._auth = _instance._client.auth;

      if (kDebugMode) {
        print('Supabase initialized successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error initializing Supabase: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  // Helper method to handle Supabase errors
  static String handleError(dynamic error) {
    if (error is AuthException) {
      return error.message;
    } else if (error is PostgrestException) {
      return error.message;
    } else if (error is StorageException) {
      return error.message;
    } else if (error is String) {
      return error;
    } else if (error is Error) {
      return error.toString();
    } else {
      return 'An unknown error occurred';
    }
  }
}
