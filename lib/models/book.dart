class Book {
  final String id;
  final String nameAr;
  final int chaptersCount;

  const Book({required this.id, required this.nameAr, required this.chaptersCount});

  factory Book.fromMap(Map<String, dynamic> map) {
    String _readName(dynamic value) => (value ?? '').toString();
    int _parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Book(
      id: _readName(
        map['id'] ?? map['book_id'] ?? map['book'] ?? map['book_number'] ?? map['number'],
      ),
      nameAr: _readName(map['name_ar'] ?? map['arabic'] ?? map['name'] ?? map['book_name'] ?? map['title']),
      chaptersCount: _parseInt(map['chapters_count'] ?? map['chapters'] ?? map['chapter_count'] ?? map['chaptersCount']),
    );
  }

  factory Book.fromApiMap(Map<String, dynamic> map, {required int fallbackNumber}) {
    final normalized = <String, dynamic>{
      ...map,
      'id': map['id'] ?? map['book_number'] ?? map['book'] ?? map['number'] ?? fallbackNumber.toString(),
      'name_ar': map['name_ar'] ?? map['arabic'] ?? map['name'] ?? map['book_name'],
      'chapters_count': map['chapters_count'] ?? map['chapters'] ?? map['chapter_count'],
    };

    return Book.fromMap(normalized);
  }
}
