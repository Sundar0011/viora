import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '/flutter_flow/flutter_flow_util.dart';

export 'database/database.dart';
export 'storage/storage.dart';

String _kSupabaseUrl = 'https://hlmymmlkgirafodcnkgg.supabase.co';
// Anon key MUST belong to the same project as _kSupabaseUrl (hlmymmlkgirafodcnkgg).
// A mismatched key (different project ref) makes Supabase reject every SDK call
// with "Invalid API key". Keep this in sync with assets/environment_values/environment.json.
String _kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsbXltbWxrZ2lyYWZvZGNua2dnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzNzM2MTcsImV4cCI6MjA5OTk0OTYxN30.hi2bFf9xUONL3tuxhI9FW-hQVL4n7gqVYNKxeV6S7Aw';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
        url: _kSupabaseUrl,
        headers: {
          'X-Client-Info': 'flutterflow',
        },
        anonKey: _kSupabaseAnonKey,
        debug: false,
        authOptions:
            FlutterAuthClientOptions(authFlowType: AuthFlowType.implicit),
      );
}
