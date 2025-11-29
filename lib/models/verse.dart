class Verse {
  final String id;
  final String bookId;
  final int chapter;
  final int verseNumber;
  final String textAr;

  const Verse({
    required this.id,
    required this.bookId,
    required this.chapter,
    required this.verseNumber,
    required this.textAr,
  });

  factory Verse.fromMap(Map<String, dynamic> map) => Verse(
        id: (map['id'] ?? map['verse_id'] ?? '').toString(),
        bookId: (map['book_id'] ?? map['book'] ?? map['bookId'] ?? '').toString(),
        chapter: _parseInt(map['chapter'] ?? map['chapter_number']),
        verseNumber: _parseInt(map['verse_number'] ?? map['verse'] ?? map['number']),
        textAr: (map['text_ar'] ?? map['text'] ?? map['content'] ?? '').toString(),
      );

  factory Verse.fromApiMap(Map<String, dynamic> map, {required String bookId, required int chapter}) {
    final verseNumber = _parseInt(map['verse'] ?? map['verse_number'] ?? map['id'] ?? map['number']);
    final text = (map['text'] ?? map['text_ar'] ?? map['content'] ?? map['verse_text'] ?? '').toString();
    final id = (map['id'] ?? map['verse_id'] ?? '$bookId-$chapter-$verseNumber').toString();

    return Verse(
      id: id,
      bookId: bookId,
      chapter: chapter,
      verseNumber: verseNumber,
      textAr: text,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
