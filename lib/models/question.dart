import 'verse.dart';

class Question {
  final Verse verse;
  final String fullText;
  final List<String> hiddenWords;
  final List<String> options;

  const Question({
    required this.verse,
    required this.fullText,
    required this.hiddenWords,
    required this.options,
  });
}
