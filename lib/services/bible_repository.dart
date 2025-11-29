import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/book.dart';
import '../models/verse.dart';
import 'arabic_bible_api.dart';
import 'supabase_client_provider.dart';

class BibleRepository {
  BibleRepository({SupabaseClient? client, ArabicBibleApi? api})
      : _client = client ?? SupabaseClientProvider.client,
        _api = api ?? ArabicBibleApi();

  final SupabaseClient _client;
  final ArabicBibleApi _api;
  final Map<String, List<Book>> _booksCache = {};
  final Map<String, List<Verse>> _versesCache = {};

  Future<List<Book>> getBooks() async {
    if (_booksCache.containsKey('books')) return _booksCache['books']!;

    final response = await _client.from('books').select();
    final books = (response as List<dynamic>).map((e) => Book.fromMap(e as Map<String, dynamic>)).toList();

    // Align with API canonical list and attach apiIndex if missing.
    final apiBooks = await _api.fetchCanonicalBooks();
    final apiByName = {for (final b in apiBooks) b.nameAr: b};

    final filtered = books
        .where((b) => apiByName.containsKey(b.nameAr))
        .map((b) {
          final apiMatch = apiByName[b.nameAr];
          return b.copyWith(apiIndex: b.apiIndex ?? apiMatch?.apiIndex);
        })
        .toList();

    _booksCache['books'] = filtered.isEmpty ? books : filtered;
    return _booksCache['books']!;
  }

  Future<int> getChapterVerseCount(String bookId, int chapter, {Book? book}) async {
    final result = await _client
        .from('verses')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('book_id', bookId)
        .eq('chapter', chapter);

    var count = result.count ?? 0;
    final apiIndex = book?.apiIndex ?? int.tryParse(bookId);
    if (apiIndex != null) {
      final chapterCounts = await _api.fetchChapterCounts();
      final apiCount = chapterCounts[apiIndex];
      if (apiCount != null && apiCount > count) count = apiCount;
    }
    return count;
  }

  Future<List<Verse>> getVersesRange(String bookId, int chapter, int fromVerse, int toVerse, {Book? book}) async {
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

    var verses = (response as List<dynamic>).map((e) => Verse.fromMap(e as Map<String, dynamic>)).toList();

    // Verify with arabic-bible API when possible.
    final apiIndex = book?.apiIndex ?? int.tryParse(bookId);
    if (apiIndex != null) {
      verses = await Future.wait(
        verses.map((v) => _api.verifyOrUpdateVerse(v, apiIndex: apiIndex)),
      );
    }

    _versesCache[cacheKey] = verses;
    return verses;
  }
}
