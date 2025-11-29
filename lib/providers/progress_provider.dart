import 'package:flutter/material.dart';

import '../models/badge.dart';
import '../models/game_config.dart';
import '../models/user_progress.dart';
import '../models/verse.dart';
import '../services/progress_service.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider({ProgressService? service}) : _service = service ?? ProgressService();

  final ProgressService _service;
  UserProgress progress = const UserProgress(
    totalVersesCompleted: 0,
    totalGamesPlayed: 0,
    totalScore: 0,
    currentLevel: 1,
    unlockedBadgeIds: <String>{},
  );
  List<Badge> badges = [];
  bool isLoading = true;
  final Set<String> favoriteVerseIds = {};

  Future<void> init() async {
    progress = await _service.loadProgress();
    badges = await _service.loadUserBadges();
    isLoading = false;
    notifyListeners();
  }

  Future<void> onQuestionEvaluated({required bool isCorrect, required int score, required Verse verse, required Difficulty difficulty}) async {
    if (isCorrect) {
      await _service.registerCorrectAnswer(verse, difficulty, score);
      progress = await _service.loadProgress();
      badges = await _service.loadUserBadges();
      notifyListeners();
    } else {
      progress = progress.copyWith(totalGamesPlayed: progress.totalGamesPlayed + 1);
      await _service.saveProgress(progress);
      notifyListeners();
    }
  }

  Future<void> saveLastConfig(Map<String, dynamic> config) async {
    progress = progress.copyWith(lastGameConfig: config);
    await _service.saveProgress(progress);
    notifyListeners();
  }

  Future<void> toggleFavorite(Verse verse) async {
    await _service.toggleFavorite(verse);
    if (favoriteVerseIds.contains(verse.id)) {
      favoriteVerseIds.remove(verse.id);
    } else {
      favoriteVerseIds.add(verse.id);
    }
    notifyListeners();
  }

  Future<bool> isFavorite(String verseId) async {
    if (favoriteVerseIds.contains(verseId)) return true;
    // Optional: refresh from Supabase
    return false;
  }
}
