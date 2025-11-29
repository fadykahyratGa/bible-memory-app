import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_config.dart';
import '../../models/question.dart';
import '../../providers/game_provider.dart';
import '../../providers/progress_provider.dart';
import '../../ui/widgets/progress_bar.dart';
import '../../ui/widgets/tile_button.dart';
import '../../ui/widgets/primary_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool isChecking = false;
  bool? lastCorrect;
  int lastScore = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final config = ModalRoute.of(context)?.settings.arguments as GameConfig?;
    final provider = context.read<GameProvider>();
    if (provider.state == null && config != null) {
      provider.startGame(config);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final progress = context.read<ProgressProvider>();
    final state = game.state;

    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = state.currentQuestion;
    final total = state.questions.length;
    final current = state.currentIndex + 1;

    return Scaffold(
      appBar: AppBar(title: const Text('أكمل الآية')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(question: question, difficulty: state.config.difficulty),
            const SizedBox(height: 12),
            Text(question.verse.textAr, style: const TextStyle(fontSize: 18, height: 1.6)),
            const SizedBox(height: 12),
            Wrap(
              children: state.currentAnswer
                  .map((w) => TileButton(
                        text: w,
                        selected: true,
                        onTap: () => game.removeOption(w),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  children: question.options
                      .map(
                        (o) => TileButton(
                          text: o,
                          selected: state.currentAnswer.contains(o),
                          onTap: () => state.currentAnswer.contains(o)
                              ? game.removeOption(o)
                              : game.selectOption(o),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Text('السؤال $current من $total'),
            const SizedBox(height: 6),
            ProgressBar(value: current / total),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    await progress.toggleFavorite(question.verse);
                  },
                  icon: const Icon(Icons.favorite_border),
                ),
                const Text('إضافة للمفضلة'),
                const Spacer(),
                Text('النقاط: ${state.score}')
              ],
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'تحقق',
              onPressed: state.currentAnswer.length == question.hiddenWords.length && !isChecking
                  ? () async {
                      setState(() => isChecking = true);
                      final result = await game.checkAnswer(progress);
                      setState(() {
                        isChecking = false;
                        lastCorrect = result.$1;
                        lastScore = result.$2;
                      });
                      if (!mounted) return;
                      Navigator.pushNamed(context, '/result', arguments: {'correct': result.$1, 'score': result.$2});
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Question question;
  final Difficulty difficulty;

  const _Header({required this.question, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final difficultyText = {
      Difficulty.easy: 'سهل',
      Difficulty.medium: 'متوسط',
      Difficulty.hard: 'صعب',
    }[difficulty]!;

    final difficultyColor = {
      Difficulty.easy: Colors.green,
      Difficulty.medium: Colors.orange,
      Difficulty.hard: Colors.red,
    }[difficulty]!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المرجع: ${question.verse.bookId} ${question.verse.chapter}:${question.verse.verseNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('أكمل الكلمات المفقودة: ${question.hiddenWords.length} كلمة'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: difficultyColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(difficultyText, style: TextStyle(color: difficultyColor, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
