import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuration class for Supabase initialization and access.
class SupabaseConfig {
  static SupabaseClient get client => Supabase.instance.client;

  /// Initializes Supabase with credentials from environment variables.
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'Missing Supabase credentials. Please check your .env file.',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
