import 'dart:math';

import '../models/game_config.dart';
import '../models/question.dart';
import '../models/verse.dart';

class GameEngine {
  List<Question> buildQuestions(List<Verse> verses, Difficulty difficulty) {
    final random = Random();
    return verses.map((verse) {
      final words = verse.textAr.split(' ');
      final hideCount = _hiddenWordsCount(difficulty, random);
      final indices = <int>{};
      while (indices.length < hideCount && indices.length < words.length) {
        indices.add(random.nextInt(words.length));
      }
      final hiddenWords = indices.map((i) => words[i]).toList();
      final distractors = _generateDistractors(words, hiddenWords, random, hideCount);
      final options = [...hiddenWords, ...distractors]..shuffle(random);
      for (final i in indices) {
        words[i] = '____';
      }
      final maskedText = words.join(' ');
      final maskedVerse = Verse(
        id: verse.id,
        bookId: verse.bookId,
        chapter: verse.chapter,
        verseNumber: verse.verseNumber,
        textAr: maskedText,
      );
      return Question(
        verse: maskedVerse,
        fullText: verse.textAr,
        hiddenWords: hiddenWords,
        options: options,
      );
    }).toList();
  }

  int _hiddenWordsCount(Difficulty difficulty, Random random) {
    switch (difficulty) {
      case Difficulty.easy:
        return random.nextInt(2) + 1; // 1-2
      case Difficulty.medium:
        return random.nextInt(2) + 2; // 2-3
      case Difficulty.hard:
        return random.nextInt(3) + 3; // 3-5
    }
  }

  List<String> _generateDistractors(List<String> words, List<String> hidden, Random random, int count) {
    final distractors = <String>[];
    final candidates = words.where((w) => !hidden.contains(w) && w.length > 2).toList();
    candidates.shuffle(random);
    for (final word in candidates) {
      if (distractors.length >= count) break;
      distractors.add(word);
    }
    // pad with duplicated hidden words if insufficient
    while (distractors.length < count && hidden.isNotEmpty) {
      distractors.add(hidden[random.nextInt(hidden.length)]);
    }
    return distractors;
  }

  bool isAnswerCorrect(Question question, List<String> userAnswer) {
    if (userAnswer.length != question.hiddenWords.length) return false;
    for (var i = 0; i < question.hiddenWords.length; i++) {
      if (question.hiddenWords[i] != userAnswer[i]) return false;
    }
    return true;
  }

  int calculateScore({required Difficulty difficulty, required bool isCorrect, required int attemptsCount}) {
    if (!isCorrect) return 0;
    final base = switch (difficulty) {
      Difficulty.easy => 5,
      Difficulty.medium => 10,
      Difficulty.hard => 15,
    };
    final bonus = max(0, 3 - attemptsCount);
    return base + bonus;
  }
}
