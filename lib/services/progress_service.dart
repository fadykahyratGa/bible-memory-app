import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/badge.dart';
import '../models/game_config.dart';
import '../models/user_progress.dart';
import '../models/verse.dart';
import 'supabase_client_provider.dart';

class ProgressService {
  ProgressService({SupabaseClient? client}) : _client = client ?? SupabaseClientProvider.client;

  final SupabaseClient _client;

  Future<UserProgress> loadProgress() async {
    final userId = _client.auth.currentUser!.id;
    final result = await _client.from('user_progress').select().eq('user_id', userId).maybeSingle();
    if (result == null) {
      await _client.from('user_progress').upsert({'user_id': userId});
      return const UserProgress(
        totalVersesCompleted: 0,
        totalGamesPlayed: 0,
        totalScore: 0,
        currentLevel: 1,
        unlockedBadgeIds: <String>{},
      );
    }
    return UserProgress.fromMap(result as Map<String, dynamic>);
  }

  Future<void> saveProgress(UserProgress progress) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('user_progress').upsert({
          'user_id': userId,
          'total_verses_completed': progress.totalVersesCompleted,
          'total_games_played': progress.totalGamesPlayed,
          'total_score': progress.totalScore,
          'current_level': progress.currentLevel,
          'last_game_config': progress.lastGameConfig,
        });
  }

  Future<void> registerCorrectAnswer(Verse verse, Difficulty difficulty, int scoreEarned) async {
    final userId = _client.auth.currentUser!.id;
    final progress = await loadProgress();
    final updated = progress.copyWith(
      totalVersesCompleted: progress.totalVersesCompleted + 1,
      totalGamesPlayed: progress.totalGamesPlayed + 1,
      totalScore: progress.totalScore + scoreEarned,
      currentLevel: 1 + (progress.totalVersesCompleted + 1) ~/ 10,
    );
    await saveProgress(updated);
    await _evaluateBadges(updated, difficulty);
  }

  Future<void> _evaluateBadges(UserProgress progress, Difficulty difficulty) async {
    final userId = _client.auth.currentUser!.id;
    final unlocked = await loadUserBadges();
    final unlockedIds = unlocked.map((b) => b.id).toSet();
    final newBadges = <String>[];
    if (progress.totalVersesCompleted >= 1) newBadges.add('first_verse');
    if (progress.totalVersesCompleted >= 5) newBadges.add('five_verses');
    if (progress.totalVersesCompleted >= 10) newBadges.add('ten_verses');
    if (difficulty == Difficulty.hard && progress.totalVersesCompleted >= 10) {
      newBadges.add('hard_worker');
    }

    for (final badgeId in newBadges) {
      if (unlockedIds.contains(badgeId)) continue;
      await _client.from('user_badges').insert({
            'user_id': userId,
            'badge_id': badgeId,
          });
    }
  }

  Future<List<Badge>> loadUserBadges() async {
    final userId = _client.auth.currentUser!.id;
    final unlocked = await _client.from('user_badges').select('badge_id').eq('user_id', userId);
    final unlockedIds = (unlocked as List<dynamic>).map((e) => e['badge_id'] as String).toSet();

    final badgesRes = await _client.from('badges').select();
    return (badgesRes as List<dynamic>)
        .map((e) => Badge.fromMap(e as Map<String, dynamic>, unlockedIds: unlockedIds))
        .toList();
  }

  Future<void> toggleFavorite(Verse verse) async {
    final userId = _client.auth.currentUser!.id;
    final existing = await _client
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('verse_id', verse.id)
        .maybeSingle();
    if (existing != null) {
      await _client.from('favorites').delete().eq('user_id', userId).eq('verse_id', verse.id);
    } else {
      await _client.from('favorites').insert({'user_id': userId, 'verse_id': verse.id});
    }
  }

  Future<bool> isFavorite(Verse verse) async {
    final userId = _client.auth.currentUser!.id;
    final existing = await _client
        .from('favorites')
        .select('verse_id')
        .eq('user_id', userId)
        .eq('verse_id', verse.id)
        .maybeSingle();
    return existing != null;
  }
}
