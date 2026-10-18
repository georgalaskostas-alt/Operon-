import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Optional development backend. Never put service-role secrets in Flutter.
/// Without both --dart-define values the existing offline app stays unchanged.
class OperonCloud {
  static const url = String.fromEnvironment('OPERON_SUPABASE_URL');
  static const publishableKey = String.fromEnvironment('OPERON_SUPABASE_PUBLISHABLE_KEY');

  static bool get configured => url.isNotEmpty && publishableKey.isNotEmpty;
  static bool get available => configured && Supabase.instance.client.auth.currentSession != null;

  static Future<void> initialize() async {
    if (!configured) {
      debugPrint('OPERON: offline mode (cloud configuration absent).');
      return;
    }
    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }

  static SupabaseClient get client {
    if (!configured) throw StateError('Cloud backend is not configured.');
    return Supabase.instance.client;
  }
}
