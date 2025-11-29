import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/book.dart';
import '../models/verse.dart';
import 'supabase_client_provider.dart';

class BibleRepository {
  BibleRepository({SupabaseClient? client}) : _client = client ?? SupabaseClientProvider.client;

  final SupabaseClient _client;
  final Map<String, List<Book>> _booksCache = {};
  final Map<String, List<Verse>> _versesCache = {};

  Future<List<Book>> getBooks() async {
    if (_booksCache.containsKey('books')) return _booksCache['books']!;
    final response = await _client.from('books').select();
    final books = (response as List<dynamic>).map((e) => Book.fromMap(e as Map<String, dynamic>)).toList();
    _booksCache['books'] = books;
    return books;
  }

  Future<int> getChapterVerseCount(String bookId, int chapter) async {
    final result = await _client
        .from('verses')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('book_id', bookId)
        .eq('chapter', chapter);
    return result.count ?? 0;
  }

  Future<List<Verse>> getVersesRange(String bookId, int chapter, int fromVerse, int toVerse) async {
    final cacheKey = '$bookId-$chapter-$fromVerse-$toVerse';
    if (_versesCache.containsKey(cacheKey)) return _versesCache[cacheKey]!;

    final response = await _client
        .from('verses')
        .select()
        .eq('book_id', bookId)
        .eq('chapter', chapter)
        .gte('verse_number', fromVerse)
        .lte('verse_number', toVerse)
        .order('verse_number');

    final verses = (response as List<dynamic>).map((e) => Verse.fromMap(e as Map<String, dynamic>)).toList();
    _versesCache[cacheKey] = verses;
    return verses;
  }
}
