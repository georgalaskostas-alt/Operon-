import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Optional development backend. Never put service-role secrets in Flutter.
/// Without both --dart-define values the existing offline app stays unchanged.
class OperonCloud {
  static const url = String.fromEnvironment('OPERON_SUPABASE_URL');
  static const anonKey = String.fromEnvironment('OPERON_SUPABASE_ANON_KEY');

  static bool get configured => url.isNotEmpty && anonKey.isNotEmpty;
  static bool get available => configured && Supabase.instance.client.auth.currentSession != null;

  static Future<void> initialize() async {
    if (!configured) {
      debugPrint('OPERON: offline mode (cloud configuration absent).');
      return;
    }
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client {
    if (!configured) throw StateError('Cloud backend is not configured.');
    return Supabase.instance.client;
  }
}
