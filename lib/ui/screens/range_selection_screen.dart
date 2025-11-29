import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/book.dart';
import '../../models/game_config.dart';
import '../../providers/game_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/bible_repository.dart';
import '../widgets/primary_button.dart';

class RangeSelectionScreen extends StatefulWidget {
  const RangeSelectionScreen({super.key});

  @override
  State<RangeSelectionScreen> createState() => _RangeSelectionScreenState();
}

class _RangeSelectionScreenState extends State<RangeSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = BibleRepository();
  List<Book> books = [];
  int? verseCount;
  Book? selectedBook;
  int? selectedChapter;
  final fromController = TextEditingController();
  final toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final data = await _repo.getBooks();
    setState(() => books = data);
  }

  Future<void> _loadVerseCount() async {
    if (selectedBook == null || selectedChapter == null) return;
    verseCount = await _repo.getChapterVerseCount(selectedBook!.id, selectedChapter!, book: selectedBook);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('اختيار الآيات')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Book>(
                decoration: const InputDecoration(labelText: 'السفر'),
                items: books
                    .map((b) => DropdownMenuItem(value: b, child: Text(b.nameAr)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBook = value;
                    selectedChapter = null;
                    verseCount = null;
                  });
                },
                validator: (value) => value == null ? 'اختر سفرًا' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'الإصحاح'),
                value: selectedChapter,
                items: selectedBook == null
                    ? []
                    : List.generate(selectedBook!.chaptersCount, (i) => i + 1)
                        .map((c) => DropdownMenuItem(value: c, child: Text('$c')))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedChapter = value;
                    verseCount = null;
                  });
                  _loadVerseCount();
                },
                validator: (value) => value == null ? 'اختر إصحاحًا' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: fromController,
                decoration: const InputDecoration(labelText: 'من عدد'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final v = int.tryParse(value ?? '');
                  if (v == null) return 'رقم غير صالح';
                  if (verseCount != null && v > verseCount!) return 'أكبر من عدد الآيات';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: toController,
                decoration: const InputDecoration(labelText: 'إلى عدد'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final v = int.tryParse(value ?? '');
                  if (v == null) return 'رقم غير صالح';
                  if (verseCount != null && v > verseCount!) return 'أكبر من عدد الآيات';
                  final from = int.tryParse(fromController.text);
                  if (from != null && v < from) return 'يجب أن يكون أكبر من أو يساوي البداية';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text('الصعوبة'),
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
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'انتقال',
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final book = selectedBook!;
                  final chapter = selectedChapter!;
                  final from = int.parse(fromController.text);
                  final to = int.parse(toController.text);
                  final config = GameConfig(
                    book: book,
                    chapter: chapter,
                    fromVerse: from,
                    toVerse: to,
                    difficulty: settings.difficulty,
                  );
                  final gameProvider = context.read<GameProvider>();
                  await gameProvider.startGame(config);
                  await context.read<ProgressProvider>().saveLastConfig(config.toJson());
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/game', arguments: config);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
