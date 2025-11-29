import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/game_provider.dart';
import '../../ui/widgets/primary_button.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final correct = args?['correct'] as bool? ?? false;
    final score = args?['score'] as int? ?? 0;
    final game = context.watch<GameProvider>();
    final state = game.state!;
    final question = state.currentQuestion;
    final isLast = state.currentIndex == state.questions.length - 1;

    return Scaffold(
      appBar: AppBar(title: const Text('النتيجة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? Colors.green : Colors.red, size: 100),
            const SizedBox(height: 12),
            Text(
              correct ? 'أحسنت! أكملت الآية بنجاح 👏' : 'محاولة جيدة! لنحاول مرة أخرى.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('الآية الكاملة:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _HighlightedVerse(fullText: question.fullText, hiddenWords: question.hiddenWords),
            const SizedBox(height: 12),
            if (correct) Text('+$score نقطة', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            const Spacer(),
            if (!isLast)
              PrimaryButton(
                label: 'التالي',
                onPressed: () {
                  game.goToNextQuestion();
                  Navigator.pop(context);
                },
              )
            else
              PrimaryButton(
                label: 'إنهاء الجلسة',
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
              ),
            if (!correct && !isLast)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('أعد المحاولة'),
              )
          ],
        ),
      ),
    );
  }
}

class _HighlightedVerse extends StatelessWidget {
  final String fullText;
  final List<String> hiddenWords;

  const _HighlightedVerse({required this.fullText, required this.hiddenWords});

  @override
  Widget build(BuildContext context) {
    final words = fullText.split(' ');
    final hiddenQueue = List<String>.from(hiddenWords);
    return Wrap(
      textDirection: TextDirection.rtl,
      children: words.map((word) {
        final isHidden = hiddenQueue.isNotEmpty && hiddenQueue.first == word;
        if (isHidden) hiddenQueue.removeAt(0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Text(
            word,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isHidden ? FontWeight.bold : FontWeight.normal,
              color: isHidden ? Theme.of(context).colorScheme.primary : Colors.black,
              decoration: isHidden ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        );
      }).toList(),
    );
  }
}
