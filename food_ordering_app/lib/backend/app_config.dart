import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- SUPABASE CONFIG FROM ENVIRONMENT VARIABLES ---
class AppConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
  static String get paystackCallbackUrl => dotenv.env['PAYSTACK_CALLBACK_URL']!;
  static bool get hasSupabase => dotenv.env['HAS_SUPABASE'] == 'true';
}
