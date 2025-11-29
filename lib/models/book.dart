class Book {
  final String id;
  final String nameAr;
  final int chaptersCount;

  const Book({required this.id, required this.nameAr, required this.chaptersCount});

  factory Book.fromMap(Map<String, dynamic> map) => Book(
        id: map['id'] as String,
        nameAr: map['name_ar'] as String,
        chaptersCount: map['chapters_count'] as int,
      );
}
