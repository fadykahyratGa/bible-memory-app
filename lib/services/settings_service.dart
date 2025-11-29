import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_config.dart';
import 'supabase_client_provider.dart';

class SettingsService {
  SettingsService({SupabaseClient? client}) : _client = client ?? SupabaseClientProvider.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>> loadSettings() async {
    final userId = _client.auth.currentUser!.id;
    final result = await _client.from('settings').select().eq('user_id', userId).maybeSingle();
    if (result == null) {
      await _client.from('settings').insert({
            'user_id': userId,
            'default_difficulty': Difficulty.easy.name,
            'sound_enabled': true,
          });
      return {'default_difficulty': Difficulty.easy.name, 'sound_enabled': true};
    }
    return result as Map<String, dynamic>;
  }

  Future<void> saveSettings({required Difficulty difficulty, required bool soundEnabled}) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('settings').upsert({
          'user_id': userId,
          'default_difficulty': difficulty.name,
          'sound_enabled': soundEnabled,
        });
  }
}
