import 'game_config.dart';
import 'question.dart';

class GameState {
  final GameConfig config;
  final List<Question> questions;
  final int currentIndex;
  final List<String> currentAnswer;
  final int score;
  final int correctCount;
  final int wrongCount;
  final bool isCompleted;

  const GameState({
    required this.config,
    required this.questions,
    required this.currentIndex,
    required this.currentAnswer,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.isCompleted,
  });

  Question get currentQuestion => questions[currentIndex];

  GameState copyWith({
    GameConfig? config,
    List<Question>? questions,
    int? currentIndex,
    List<String>? currentAnswer,
    int? score,
    int? correctCount,
    int? wrongCount,
    bool? isCompleted,
  }) {
    return GameState(
      config: config ?? this.config,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      currentAnswer: currentAnswer ?? this.currentAnswer,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
