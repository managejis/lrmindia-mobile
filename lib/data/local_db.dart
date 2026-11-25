import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// Offline copy of the Supabase tables (same names/columns) so the app reads everything from the phone.
class LocalDb {
  LocalDb._();
  static final LocalDb instance = LocalDb._();
  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'abba_sunday_school.db');
    return openDatabase(path, version: 5, onUpgrade: (d, oldV, newV) async {
      if (oldV < 4) {
        // Odia and Urdu lessons are now available (were "coming soon")
        await d.execute("UPDATE languages SET active=1 WHERE code IN ('or','ur')");
      }
      if (oldV < 5) {
        // nine International languages added after Malayalam
        await _seedLanguages(d);
      }
      if (oldV < 2) {
        await d.execute('CREATE TABLE IF NOT EXISTS progress(lang_code TEXT NOT NULL, book_no INTEGER NOT NULL, lesson_no INTEGER NOT NULL, done_at TEXT, PRIMARY KEY(lang_code, book_no, lesson_no))');
        await d.execute('ALTER TABLE songs ADD COLUMN youtube_url TEXT');
        await d.execute('DELETE FROM sync_state');   // fetch everything again so the new columns are filled
      }
      if (oldV < 3) {
        await d.execute('ALTER TABLE languages ADD COLUMN active INTEGER DEFAULT 1');
        await d.execute('DELETE FROM sync_state');
        await _seedLanguages(d);
      }
    }, onCreate: (d, v) async {
      await d.execute('''CREATE TABLE languages(
        code TEXT PRIMARY KEY, name TEXT NOT NULL, native_name TEXT NOT NULL, glyph TEXT NOT NULL,
        web_folder TEXT NOT NULL, hero_lead TEXT, sort_order INTEGER DEFAULT 0, active INTEGER DEFAULT 1, updated_at TEXT)''');
      await d.execute('''CREATE TABLE books(
        lang_code TEXT NOT NULL, book_no INTEGER NOT NULL, title_en TEXT NOT NULL, title_native TEXT,
        folder TEXT NOT NULL, color_a TEXT, color_b TEXT, icon TEXT, lesson_count INTEGER DEFAULT 0, updated_at TEXT,
        PRIMARY KEY(lang_code, book_no))''');
      await d.execute('''CREATE TABLE lessons(
        lang_code TEXT NOT NULL, book_no INTEGER NOT NULL, lesson_no INTEGER NOT NULL,
        title_native TEXT NOT NULL, title_en TEXT, updated_at TEXT,
        PRIMARY KEY(lang_code, book_no, lesson_no))''');
      await d.execute('''CREATE TABLE lesson_contents(
        lang_code TEXT NOT NULL, book_no INTEGER NOT NULL, lesson_no INTEGER NOT NULL, kind TEXT NOT NULL,
        body TEXT NOT NULL, updated_at TEXT,
        PRIMARY KEY(lang_code, book_no, lesson_no, kind))''');
      await d.execute('''CREATE TABLE songs(
        lang_code TEXT NOT NULL, song_no INTEGER NOT NULL, title_native TEXT NOT NULL, title_en TEXT,
        lyrics_native TEXT NOT NULL, lyrics_en TEXT, youtube_url TEXT, updated_at TEXT,
        PRIMARY KEY(lang_code, song_no))''');
      await d.execute('CREATE TABLE progress(lang_code TEXT NOT NULL, book_no INTEGER NOT NULL, lesson_no INTEGER NOT NULL, done_at TEXT, PRIMARY KEY(lang_code, book_no, lesson_no))');
      await d.execute('CREATE TABLE sync_state(lang_code TEXT NOT NULL, tbl TEXT NOT NULL, last_sync TEXT, PRIMARY KEY(lang_code, tbl))');
      await _seedLanguages(d);
    });
  }

  /// Built-in language list (in the order shown) so the first screen works before the first sync / without internet.
  /// Odia and Urdu have no lessons yet ("coming soon").
  static const _builtin = <List<Object>>[
    ['en', 'English', 'English', 'E', 'English', 1, 1],
    ['ta', 'Tamil', 'தமிழ்', 'த', 'Tamil', 2, 1],
    ['te', 'Telugu', 'తెలుగు', 'తె', 'Telugu', 3, 1],
    ['kn', 'Kannada', 'ಕನ್ನಡ', 'ಕ', 'Kannada', 4, 1],
    ['bn', 'Bengali', 'বাংলা', 'বা', 'Bengali', 5, 1],
    ['gu', 'Gujarati', 'ગુજરાતી', 'ગુ', 'Gujarati', 6, 1],
    ['ml', 'Malayalam', 'മലയാളം', 'മ', 'Malayalam', 7, 1],
    ['mr', 'Marathi', 'मराठी', 'म', 'Marathi', 8, 1],
    ['hi', 'Hindi', 'हिन्दी', 'हि', 'Hindi', 9, 1],
    ['or', 'Odia', 'ଓଡ଼ିଆ', 'ଓ', 'Odia', 10, 1],
    ['ur', 'Urdu', 'اردو', 'ا', 'Urdu', 11, 1],
    ['zh', 'Mandarin Chinese', '中文', '中', 'Mandarin-Chinese', 12, 1],
    ['es', 'Spanish', 'Español', 'Es', 'Spanish', 13, 1],
    ['ar', 'Standard Arabic', 'العربية', 'ع', 'Standard-Arabic', 14, 1],
    ['fr', 'French', 'Français', 'Fr', 'French', 15, 1],
    ['pt', 'Portuguese', 'Português', 'Pt', 'Portuguese', 16, 1],
    ['id', 'Indonesian', 'Bahasa Indonesia', 'Id', 'Indonesian', 17, 1],
    ['ru', 'Russian', 'Русский', 'Р', 'Russian', 18, 1],
    ['de', 'German', 'Deutsch', 'De', 'German', 19, 1],
    ['ja', 'Japanese', '日本語', '日', 'Japanese', 20, 1],
  ];

  static Future<void> _seedLanguages(Database d) async {
    for (final l in _builtin) {
      final row = {'code': l[0], 'name': l[1], 'native_name': l[2], 'glyph': l[3], 'web_folder': l[4], 'sort_order': l[5], 'active': l[6]};
      final n = await d.update('languages', {'sort_order': l[5]}, where: 'code=?', whereArgs: [l[0]]);
      if (n == 0) await d.insert('languages', row);
    }
  }

  // ---------------------------------------------------------------- sync helpers
  Future<String?> lastSync(String lang, String table) async {
    final r = await (await db).query('sync_state', where: 'lang_code=? AND tbl=?', whereArgs: [lang, table]);
    return r.isEmpty ? null : r.first['last_sync'] as String?;
  }

  Future<void> setLastSync(String lang, String table, String ts) async =>
      (await db).insert('sync_state', {'lang_code': lang, 'tbl': table, 'last_sync': ts}, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    final batch = (await db).batch();
    for (final r in rows) {
      batch.insert(table, r, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------- reads
  /// The order languages are shown in (lessons and songs lists). Fixed here so that it does not depend on the database.
  static const languageOrder = ['en', 'hi', 'bn', 'mr', 'te', 'ta', 'gu', 'ur', 'kn', 'or', 'ml', 'zh', 'es', 'ar', 'fr', 'pt', 'id', 'ru', 'de', 'ja'];

  Future<List<Language>> languages() async {
    final list = (await (await db).query('languages')).map(Language.fromMap).toList();
    int rank(Language l) {
      final i = languageOrder.indexOf(l.code);
      return i < 0 ? languageOrder.length : i;
    }
    list.sort((a, b) {
      final c = rank(a).compareTo(rank(b));
      return c != 0 ? c : a.name.compareTo(b.name);
    });
    return list;
  }

  Future<Language?> language(String code) async {
    final r = await (await db).query('languages', where: 'code=?', whereArgs: [code]);
    return r.isEmpty ? null : Language.fromMap(r.first);
  }

  Future<List<Book>> books(String lang) async =>
      (await (await db).query('books', where: 'lang_code=?', whereArgs: [lang], orderBy: 'book_no')).map(Book.fromMap).toList();

  Future<List<Lesson>> lessons(String lang, {int? bookNo}) async {
    final r = await (await db).query('lessons',
        where: bookNo == null ? 'lang_code=?' : 'lang_code=? AND book_no=?',
        whereArgs: bookNo == null ? [lang] : [lang, bookNo],
        orderBy: 'book_no, lesson_no');
    return r.map(Lesson.fromMap).toList();
  }

  Future<int> lessonCount(String lang) async =>
      Sqflite.firstIntValue(await (await db).rawQuery('SELECT COUNT(*) FROM lessons WHERE lang_code=?', [lang])) ?? 0;

  Future<Map<String, String>> contents(String lang, int bookNo, int lessonNo) async {
    final r = await (await db).query('lesson_contents',
        columns: ['kind', 'body'], where: 'lang_code=? AND book_no=? AND lesson_no=?', whereArgs: [lang, bookNo, lessonNo]);
    return {for (final m in r) m['kind'] as String: m['body'] as String};
  }

  // ---------------------------------------------------------------- completed lessons (stays on the phone only)
  Future<Set<String>> completed(String lang) async {
    final r = await (await db).query('progress', where: 'lang_code=?', whereArgs: [lang]);
    return {for (final m in r) '${m['book_no']}:${m['lesson_no']}'};
  }

  Future<void> setCompleted(String lang, int bookNo, int lessonNo, bool done) async {
    final d = await db;
    if (done) {
      await d.insert('progress', {'lang_code': lang, 'book_no': bookNo, 'lesson_no': lessonNo, 'done_at': DateTime.now().toIso8601String()},
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await d.delete('progress', where: 'lang_code=? AND book_no=? AND lesson_no=?', whereArgs: [lang, bookNo, lessonNo]);
    }
  }

  /// First lesson (in book order) that is not ticked as completed - used for the Sunday preparation alert.
  Future<Lesson?> nextLesson(String lang) async {
    final done = await completed(lang);
    for (final l in await lessons(lang)) {
      if (!done.contains('${l.bookNo}:${l.lessonNo}')) return l;
    }
    return null;
  }

  Future<List<Song>> songs(String lang) async =>
      (await (await db).query('songs', where: 'lang_code=?', whereArgs: [lang], orderBy: 'song_no')).map(Song.fromMap).toList();
}
