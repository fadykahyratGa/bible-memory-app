import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/progress_provider.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الأوسمة')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: progress.badges.length,
        itemBuilder: (context, index) {
          final badge = progress.badges[index];
          return GestureDetector(
            onTap: () => _showBadgeDetails(context, badge.nameAr, badge.descriptionAr, badge.unlocked),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: badge.unlocked ? Colors.orange : Colors.grey.shade300,
                  child: Icon(
                    badge.unlocked ? Icons.emoji_events : Icons.lock,
                    color: badge.unlocked ? Colors.white : Colors.grey,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 6),
                Text(badge.nameAr, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, String name, String description, bool unlocked) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: unlocked ? Colors.orange : Colors.grey.shade300,
              child: Icon(unlocked ? Icons.emoji_events : Icons.lock, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(unlocked ? 'تم فتح الوسام' : 'لم يُفتح بعد', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
