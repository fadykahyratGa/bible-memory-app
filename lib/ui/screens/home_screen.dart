import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_config.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../ui/widgets/app_card.dart';
import '../../ui/widgets/primary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('احفظ كلمة الله'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => Navigator.pushNamed(context, '/badges'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (progress.progress.lastGameConfig != null)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('متابعة آخر جلسة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('الإصحاح: ${progress.progress.lastGameConfig!['chapter']}'),
                      Text('من: ${progress.progress.lastGameConfig!['from_verse']} - إلى: ${progress.progress.lastGameConfig!['to_verse']}'),
                      Text('الصعوبة: ${(progress.progress.lastGameConfig!['difficulty'] as String)}'),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'متابعة',
                        onPressed: () {
                          Navigator.pushNamed(context, '/game', arguments: GameConfig.fromJson(progress.progress.lastGameConfig!));
                        },
                      ),
                    ],
                  ),
                ),
              PrimaryButton(
                label: 'اختيار آيات جديدة',
                onPressed: () => Navigator.pushNamed(context, '/select-range'),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ملخص تقدّمك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('مستوىك الحالي: ${progress.progress.currentLevel}'),
                    Text('آيات مكتملة: ${progress.progress.totalVersesCompleted}'),
                    Text('مجموع النقاط: ${progress.progress.totalScore}'),
                    const SizedBox(height: 8),
                    Text('الصعوبة المفضلة: ${settings.difficulty == Difficulty.easy ? 'سهل' : settings.difficulty == Difficulty.medium ? 'متوسط' : 'صعب'}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
