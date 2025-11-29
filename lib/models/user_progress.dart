class UserProgress {
  final int totalVersesCompleted;
  final int totalGamesPlayed;
  final int totalScore;
  final int currentLevel;
  final Set<String> unlockedBadgeIds;
  final Map<String, dynamic>? lastGameConfig;

  const UserProgress({
    required this.totalVersesCompleted,
    required this.totalGamesPlayed,
    required this.totalScore,
    required this.currentLevel,
    required this.unlockedBadgeIds,
    this.lastGameConfig,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) => UserProgress(
        totalVersesCompleted: map['total_verses_completed'] as int? ?? 0,
        totalGamesPlayed: map['total_games_played'] as int? ?? 0,
        totalScore: map['total_score'] as int? ?? 0,
        currentLevel: map['current_level'] as int? ?? 1,
        unlockedBadgeIds: <String>{},
        lastGameConfig: map['last_game_config'] as Map<String, dynamic>?,
      );

  UserProgress copyWith({
    int? totalVersesCompleted,
    int? totalGamesPlayed,
    int? totalScore,
    int? currentLevel,
    Set<String>? unlockedBadgeIds,
    Map<String, dynamic>? lastGameConfig,
  }) {
    return UserProgress(
      totalVersesCompleted: totalVersesCompleted ?? this.totalVersesCompleted,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalScore: totalScore ?? this.totalScore,
      currentLevel: currentLevel ?? this.currentLevel,
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
      lastGameConfig: lastGameConfig ?? this.lastGameConfig,
    );
  }
}
