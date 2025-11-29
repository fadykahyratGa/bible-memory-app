import 'package:flutter/material.dart';

import '../models/game_config.dart';
import '../models/game_state.dart';
import '../models/question.dart';
import '../services/bible_repository.dart';
import '../services/game_engine.dart';
import 'progress_provider.dart';

class GameProvider extends ChangeNotifier {
  GameProvider({BibleRepository? repository, GameEngine? engine})
      : _repository = repository ?? BibleRepository(),
        _engine = engine ?? GameEngine();

  final BibleRepository _repository;
  final GameEngine _engine;
  GameState? state;
  int attemptsCount = 0;

  Future<void> startGame(GameConfig config) async {
    final verses = await _repository.getVersesRange(
      config.book.id,
      config.chapter,
      config.fromVerse,
      config.toVerse,
      book: config.book,
    );
    final questions = _engine.buildQuestions(verses, config.difficulty);
    state = GameState(
      config: config,
      questions: questions,
      currentIndex: 0,
      currentAnswer: [],
      score: 0,
      correctCount: 0,
      wrongCount: 0,
      isCompleted: false,
    );
    attemptsCount = 0;
    notifyListeners();
  }

  void selectOption(String word) {
    if (state == null) return;
    final current = state!;
    final updatedAnswer = [...current.currentAnswer, word];
    state = current.copyWith(currentAnswer: updatedAnswer);
    notifyListeners();
  }

  void removeOption(String word) {
    if (state == null) return;
    final current = state!;
    final updated = [...current.currentAnswer]..remove(word);
    state = current.copyWith(currentAnswer: updated);
    notifyListeners();
  }

  void clearAnswer() {
    if (state == null) return;
    state = state!.copyWith(currentAnswer: []);
    attemptsCount = 0;
    notifyListeners();
  }

  Future<(bool isCorrect, int score)> checkAnswer(ProgressProvider progressProvider) async {
    if (state == null) return (false, 0);
    final current = state!;
    final question = current.currentQuestion;
    final isCorrect = _engine.isAnswerCorrect(question, current.currentAnswer);
    attemptsCount++;
    final earned = _engine.calculateScore(
      difficulty: current.config.difficulty,
      isCorrect: isCorrect,
      attemptsCount: attemptsCount,
    );
    final updatedScore = current.score + earned;
    final correctCount = current.correctCount + (isCorrect ? 1 : 0);
    final wrongCount = current.wrongCount + (isCorrect ? 0 : 1);
    state = current.copyWith(
      score: updatedScore,
      correctCount: correctCount,
      wrongCount: wrongCount,
    );
    await progressProvider.onQuestionEvaluated(
      isCorrect: isCorrect,
      score: earned,
      verse: question.verse,
      difficulty: current.config.difficulty,
    );
    notifyListeners();
    return (isCorrect, earned);
  }

  void goToNextQuestion() {
    if (state == null) return;
    final current = state!;
    final nextIndex = current.currentIndex + 1;
    state = current.copyWith(
      currentIndex: nextIndex,
      currentAnswer: [],
      isCompleted: nextIndex >= current.questions.length,
    );
    attemptsCount = 0;
    notifyListeners();
  }
}
