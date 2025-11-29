import 'package:flutter/material.dart';

import '../models/game_config.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({SettingsService? service}) : _service = service ?? SettingsService();

  final SettingsService _service;
  Difficulty difficulty = Difficulty.easy;
  bool soundEnabled = true;
  bool isLoading = true;

  Future<void> init() async {
    final data = await _service.loadSettings();
    difficulty = Difficulty.values.firstWhere(
      (d) => d.name == data['default_difficulty'],
      orElse: () => Difficulty.easy,
    );
    soundEnabled = data['sound_enabled'] as bool? ?? true;
    isLoading = false;
    notifyListeners();
  }

  Future<void> setDifficulty(Difficulty value) async {
    difficulty = value;
    notifyListeners();
    await _service.saveSettings(difficulty: difficulty, soundEnabled: soundEnabled);
  }

  Future<void> toggleSound(bool enabled) async {
    soundEnabled = enabled;
    notifyListeners();
    await _service.saveSettings(difficulty: difficulty, soundEnabled: soundEnabled);
  }
}
