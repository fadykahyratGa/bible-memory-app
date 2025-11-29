import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../models/verse.dart';

class BibleRepository {
  BibleRepository({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://arabic-bible.onrender.com';
  static const _maxCanonicalBooks = 66;

  final http.Client _client;
  final Map<String, List<Book>> _booksCache = {};
  final Map<String, List<Verse>> _versesCache = {};
  final Map<String, List<Verse>> _chapterCache = {};
  final Map<String, Map<int, int>> _verseCountCache = {};

  Future<List<Book>> getBooks() async {
    if (_booksCache.containsKey('books')) return _booksCache['books']!;

    final uri = Uri.parse('$_baseUrl/api/json/books');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('فشل في تحميل الأسفار (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    final rawList = decoded is List
        ? decoded
        : decoded is Map<String, dynamic> && decoded['books'] is List
            ? decoded['books'] as List<dynamic>
            : <dynamic>[];

    final books = <Book>[];
    for (var i = 0; i < rawList.length; i++) {
      final entry = rawList[i];
      if (entry is! Map<String, dynamic>) continue;
      books.add(Book.fromApiMap(entry, fallbackNumber: i + 1));
    }

    final canonicalBooks = <Book>[];
    for (var i = 0; i < books.length; i++) {
      final book = books[i];
      final bookNumber = int.tryParse(book.id) ?? i + 1;
      if (bookNumber <= _maxCanonicalBooks) {
        canonicalBooks.add(book);
      }
    }

    _booksCache['books'] = canonicalBooks;
    return canonicalBooks;
  }

  Future<int> getChapterVerseCount(String bookId, int chapter) async {
    await _warmVerseCounts();
    final cachedCount = _verseCountCache[bookId]?[chapter];
    if (cachedCount != null) return cachedCount;

    final verses = await _loadChapter(bookId, chapter);
    final count = verses.length;
    _verseCountCache.putIfAbsent(bookId, () => {})[chapter] = count;
    return count;
  }

  Future<List<Verse>> getVersesRange(String bookId, int chapter, int fromVerse, int toVerse) async {
    final cacheKey = '$bookId-$chapter-$fromVerse-$toVerse';
    if (_versesCache.containsKey(cacheKey)) return _versesCache[cacheKey]!;

    final verses = await _loadChapter(bookId, chapter);
    final filtered = verses
        .where((v) => v.verseNumber >= fromVerse && v.verseNumber <= toVerse)
        .toList();
    _versesCache[cacheKey] = filtered;
    return filtered;
  }

  Future<List<Verse>> _loadChapter(String bookId, int chapter) async {
    final cacheKey = '$bookId-$chapter';
    if (_chapterCache.containsKey(cacheKey)) return _chapterCache[cacheKey]!;

    final uri = Uri.parse('$_baseUrl/api').replace(queryParameters: {
      'book': bookId,
      'chapter': chapter.toString(),
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('فشل في تحميل الإصحاح ($bookId:$chapter): ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);
    final versesJson = _extractVersesList(decoded);

    final verses = <Verse>[];
    for (final entry in versesJson) {
      if (entry is! Map<String, dynamic>) continue;
      final verse = Verse.fromApiMap(entry, bookId: bookId, chapter: chapter);
      if (verse.verseNumber > 0 && verse.textAr.isNotEmpty) {
        verses.add(verse);
      }
    }

    _chapterCache[cacheKey] = verses;
    _verseCountCache.putIfAbsent(bookId, () => {})[chapter] = verses.length;
    return verses;
  }

  Future<void> _warmVerseCounts() async {
    if (_verseCountCache.isNotEmpty) return;

    try {
      final response = await _client.get(Uri.parse('$_baseUrl/api/json/chapters'));
      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return;

      decoded.forEach((bookKey, value) {
        final counts = <int, int>{};
        if (value is List) {
          for (var i = 0; i < value.length; i++) {
            final count = _parseInt(value[i]);
            if (count > 0) counts[i + 1] = count;
          }
        } else if (value is Map<String, dynamic>) {
          value.forEach((chapterKey, chapterValue) {
            final chapterIndex = int.tryParse(chapterKey) ?? 0;
            final count = _parseInt(chapterValue);
            if (chapterIndex > 0 && count > 0) {
              counts[chapterIndex] = count;
            }
          });
        }

        if (counts.isNotEmpty) {
          _verseCountCache[bookKey.toString()] = counts;
        }
      });
    } catch (_) {
      // Ignore and fall back to on-demand chapter fetches.
    }
  }

  List<dynamic> _extractVersesList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      if (decoded['verses'] is List) return decoded['verses'] as List<dynamic>;
      if (decoded['data'] is List) return decoded['data'] as List<dynamic>;
    }
    return <dynamic>[];
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
