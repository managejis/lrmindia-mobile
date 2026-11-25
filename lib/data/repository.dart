import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import 'local_db.dart';

/// Copies the text of one language from Supabase into the phone's SQLite database.
/// First run downloads everything (a few MB, shown with a progress bar); later runs only fetch rows that
/// changed since the last sync (updated_at), so it is quick and also works when offline (it simply skips).
class Repository {
  Repository._();
  static final Repository instance = Repository._();

  SupabaseClient get _c => Supabase.instance.client;

  // table -> (columns used to order rows deterministically, page size)
  static const _tables = <String, (List<String>, int)>{
    'languages': (['code'], 200),
    'books': (['book_no'], 200),
    'lessons': (['book_no', 'lesson_no'], 500),
    'lesson_contents': (['book_no', 'lesson_no', 'kind'], 60),
    'songs': (['song_no'], 200),
  };

  /// Returns number of rows downloaded. Throws when Supabase can't be reached (callers decide what to show).
  Future<int> syncLanguage(String lang, {void Function(double progress, String message)? onProgress}) async {
    if (!AppConfig.configured) throw StateError('Supabase is not configured yet (see lib/config.dart).');
    final db = LocalDb.instance;
    var total = 0;
    var step = 0;
    for (final entry in _tables.entries) {
      final table = entry.key;
      final since = await db.lastSync(lang, table);
      final started = DateTime.now().toUtc().toIso8601String();
      onProgress?.call(step / _tables.length, _label(table));
      var from = 0;
      final (orderCols, page) = entry.value;
      while (true) {
        var q = _c.from(table).select();
        q = table == 'languages' ? q.eq('code', lang) : q.eq('lang_code', lang);
        if (since != null) q = q.gt('updated_at', since);
        var o = q.order('updated_at');
        for (final col in orderCols) {
          o = o.order(col);
        }
        final rows = List<Map<String, dynamic>>.from(await o.range(from, from + page - 1));
        if (table == 'languages') {
          for (final r in rows) {
            if (r['active'] is bool) r['active'] = (r['active'] as bool) ? 1 : 0;   // SQLite has no boolean
          }
        }
        await db.upsert(table, rows);
        total += rows.length;
        onProgress?.call((step + 0.5) / _tables.length, '${_label(table)} ($total)');
        if (rows.length < page) break;
        from += page;
      }
      // small safety margin so rows written while we were downloading are picked up next time
      await db.setLastSync(lang, table, DateTime.parse(started).subtract(const Duration(minutes: 2)).toIso8601String());
      step++;
    }
    onProgress?.call(1, 'Done');
    return total;
  }

  String _label(String t) => switch (t) {
        'languages' => 'Language',
        'books' => 'Books',
        'lessons' => 'Lessons',
        'lesson_contents' => 'Lesson texts',
        'songs' => 'Songs',
        _ => t,
      };
}
