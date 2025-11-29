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
        id: map['id'] as String,
        bookId: map['book_id'] as String,
        chapter: map['chapter'] as int,
        verseNumber: map['verse_number'] as int,
        textAr: map['text_ar'] as String,
      );
}
