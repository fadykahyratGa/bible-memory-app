import 'book.dart';

enum Difficulty { easy, medium, hard }

class GameConfig {
  final Book book;
  final int chapter;
  final int fromVerse;
  final int toVerse;
  final Difficulty difficulty;

  const GameConfig({
    required this.book,
    required this.chapter,
    required this.fromVerse,
    required this.toVerse,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
        'book': {
          'id': book.id,
          'name_ar': book.nameAr,
          'chapters_count': book.chaptersCount,
        },
        'chapter': chapter,
        'from_verse': fromVerse,
        'to_verse': toVerse,
        'difficulty': difficulty.name,
      };

  factory GameConfig.fromJson(Map<String, dynamic> json) => GameConfig(
        book: Book.fromMap(json['book'] as Map<String, dynamic>),
        chapter: json['chapter'] as int,
        fromVerse: json['from_verse'] as int,
        toVerse: json['to_verse'] as int,
        difficulty: Difficulty.values.firstWhere(
          (d) => d.name == json['difficulty'],
          orElse: () => Difficulty.easy,
        ),
      );
}
