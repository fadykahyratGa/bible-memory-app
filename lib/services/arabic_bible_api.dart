import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../models/verse.dart';

/// Lightweight REST helper to validate verses against arabic-bible.onrender.com.
class ArabicBibleApi {
  ArabicBibleApi({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://arabic-bible.onrender.com';
  final http.Client _client;

  /// Some APIs might return deuterocanonical books; keep them out of the app.
  static const Set<String> _apocrypha = {
    'طوبيا',
    'يهوديت',
    'يشوع بن سيراخ',
    'باروك',
    'حكمة',
    'مكابيين الأول',
    'مكابيين الثاني',
  };

  Future<List<Book>> fetchCanonicalBooks() async {
    final uri = Uri.parse('$_baseUrl/api/json/books');
    final response = await _client.get(uri);
    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => e as Map<String, dynamic>)
        .where((map) => !_apocrypha.contains(map['name'] as String? ?? ''))
        .map(
          (map) => Book(
            id: (map['id'] ?? '').toString(),
            nameAr: map['name'] as String? ?? '',
            chaptersCount: (map['chapters'] as num?)?.toInt() ?? 0,
            apiIndex: (map['id'] as num?)?.toInt(),
          ),
        )
        .toList();
  }

  Future<Map<int, int>> fetchChapterCounts() async {
    final uri = Uri.parse('$_baseUrl/api/json/chapters');
    final response = await _client.get(uri);
    if (response.statusCode != 200) return {};
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data.map((key, value) => MapEntry(int.parse(key), (value as num).toInt()));
  }

  /// Fetches verse text from the API using simple query params.
  Future<String?> fetchVerseText({
    required int bookIndex,
    required int chapter,
    required int verse,
  }) async {
    final uri = Uri.parse('$_baseUrl/api').replace(queryParameters: {
      'book': bookIndex.toString(),
      'chapter': chapter.toString(),
      'verse': verse.toString(),
    });
    final response = await _client.get(uri);
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['text'] is String) return body['text'] as String;
      if (body['result'] is String) return body['result'] as String;
    } else if (body is String) {
      return body;
    }
    return null;
  }

  /// Verify that a verse matches the remote source; returns updated verse if available.
  Future<Verse> verifyOrUpdateVerse(Verse verse, {int? apiIndex}) async {
    if (apiIndex == null) return verse;
    final text = await fetchVerseText(
      bookIndex: apiIndex,
      chapter: verse.chapter,
      verse: verse.verseNumber,
    );
    if (text == null || text.isEmpty) return verse;
    return verse.copyWith(textAr: text.trim());
  }
}
