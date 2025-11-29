import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_config.dart';
import '../../providers/settings_provider.dart';
import '../../ui/widgets/primary_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مستوى الصعوبة'),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: [
                settings.difficulty == Difficulty.easy,
                settings.difficulty == Difficulty.medium,
                settings.difficulty == Difficulty.hard,
              ],
              onPressed: (index) => settings.setDifficulty(Difficulty.values[index]),
              borderRadius: BorderRadius.circular(12),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('سهل')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('متوسط')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('صعب')),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: settings.soundEnabled,
              onChanged: settings.toggleSound,
              title: const Text('الصوت'),
            ),
            const Spacer(),
            PrimaryButton(label: 'تم', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
