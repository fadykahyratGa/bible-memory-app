class Book {
  final String id;
  final String nameAr;
  final int chaptersCount;
  final int? apiIndex;

  const Book({
    required this.id,
    required this.nameAr,
    required this.chaptersCount,
    this.apiIndex,
  });

  factory Book.fromMap(Map<String, dynamic> map) => Book(
        id: map['id'] as String,
        nameAr: map['name_ar'] as String,
        chaptersCount: map['chapters_count'] as int,
        apiIndex: map['api_index'] as int?,
      );

  Book copyWith({int? apiIndex}) => Book(
        id: id,
        nameAr: nameAr,
        chaptersCount: chaptersCount,
        apiIndex: apiIndex ?? this.apiIndex,
      );
}
