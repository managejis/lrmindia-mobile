import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../config.dart';
import '../data/local_db.dart';
import '../data/models.dart';
import '../data/pdf_downloader.dart';
import '../data/repository.dart';
import '../data/ui_strings.dart';
import '../settings.dart';
import '../theme.dart';
import 'app_drawer.dart';
import 'lesson_screen.dart';
import 'songs_screen.dart';

/// Landing page of a language (same layout as Christian-Sunday-School-Kids-Children-Lessons-<Language>.html):
/// hero, stats, search, then the nine book cards with their lessons.
class LanguageHomeScreen extends StatefulWidget {
  final Language language;
  const LanguageHomeScreen({super.key, required this.language});
  @override
  State<LanguageHomeScreen> createState() => _LanguageHomeScreenState();
}

class _LanguageHomeScreenState extends State<LanguageHomeScreen> {
  List<Book> _books = [];
  List<Lesson> _lessons = [];
  Set<String> _done = {};     // 'book:lesson' of lessons ticked as completed
  bool _loading = true;
  double _progress = 0;
  String _msg = 'Preparing…';
  String? _error;
  String _q = '';
  bool _refreshing = false;

  Language get lang => widget.language;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _loadLocal() async {
    final b = await LocalDb.instance.books(lang.code);
    final l = await LocalDb.instance.lessons(lang.code);
    final d = await LocalDb.instance.completed(lang.code);
    if (mounted) setState(() { _books = b; _lessons = l; _done = d; });
  }

  Future<void> _init() async {
    AppSettings.instance.setLastLang(lang.code);
    await _loadLocal();
    if (_lessons.isNotEmpty) {
      setState(() => _loading = false);
      _backgroundSync();           // quiet update when internet is available
    } else {
      await _firstSync();
    }
  }

  Future<void> _firstSync() async {
    setState(() { _loading = true; _error = null; _progress = 0; _msg = 'Downloading lessons for offline use…'; });
    try {
      await Repository.instance.syncLanguage(lang.code, onProgress: (p, m) { if (mounted) setState(() { _progress = p; _msg = m; }); });
      await _loadLocal();
      if (_lessons.isEmpty) _error = 'No lessons found for ${lang.name} yet.';
    } catch (e) {
      _error = AppConfig.configured
          ? 'Could not download the lessons. Please check your internet connection and try again.'
          : 'The app is not connected to Supabase yet (lib/config.dart).';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _backgroundSync() async {
    try {
      if (mounted) setState(() => _refreshing = true);
      final n = await Repository.instance.syncLanguage(lang.code);
      if (n > 0) await _loadLocal();
    } catch (_) {/* offline - keep using the saved copy */} finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leadingWidth: 104,
        leading: Builder(
          builder: (ctx) => Row(children: [
            IconButton(tooltip: 'Menu', icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(ctx).openDrawer()),
            IconButton(tooltip: 'Back', icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
          ]),
        ),
        title: Text(lang.code == 'en' ? lang.name : lang.nativeName),
        actions: [
          if (_refreshing) const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
          IconButton(
            tooltip: 'Songs',
            icon: const Icon(Icons.music_note),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SongsScreen(language: lang))),
          ),
        ],
      ),
      body: _loading ? _syncView() : (_error != null && _books.isEmpty ? _errorView() : _content()),
    );
  }

  Widget _syncView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.cloud_download_outlined, size: 56, color: Brand.accent),
            const SizedBox(height: 16),
            Text(_msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 18),
            LinearProgressIndicator(value: _progress == 0 ? null : _progress, color: Brand.accent, minHeight: 6, borderRadius: BorderRadius.circular(6)),
            const SizedBox(height: 10),
            Text('Only the first time. After that it works offline.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ]),
        ),
      );

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.wifi_off, size: 56, color: Brand.accent),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: _firstSync, icon: const Icon(Icons.refresh), label: const Text('Try again')),
          ]),
        ),
      );

  Widget _content() {
    final q = _q.trim().toLowerCase();
    final cards = <Widget>[];
    for (final b in _books) {
      final all = _lessons.where((l) => l.bookNo == b.bookNo).toList();
      final hit = q.isEmpty ? all : all.where((l) => l.titleNative.toLowerCase().contains(q) || (l.titleEn ?? '').toLowerCase().contains(q) || '${l.lessonNo}' == q).toList();
      final titleHit = q.isNotEmpty && ('book ${b.bookNo} ${b.titleEn}'.toLowerCase().contains(q));
      if (q.isNotEmpty && hit.isEmpty && !titleHit) continue;
      cards.add(Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _BookCard(book: b, lessons: all, shown: titleHit ? all : hit, forceOpen: q.isNotEmpty && hit.isNotEmpty, lang: lang, done: _done, onBack: _loadLocal),
      ));
    }
    final ui = UiStrings.of(lang.code);
    final regional = lang.code != 'en';
    final headline = regional ? '${lang.nativeName} - ${ui.tail}' : '${lang.name} - Bible Lessons for Kids & Children';
    return Directionality(
      textDirection: lang.textDirection,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Icon(Icons.menu_book, size: 18, color: Brand.accent),
            Text(ui.kicker, style: TextStyle(color: Brand.accent, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 8),
          Text(headline, style: const TextStyle(fontSize: 26, height: 1.3, fontWeight: FontWeight.w800, color: Brand.heading)),
          if (regional)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('${lang.name} - Bible Lessons for Kids & Children', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(regional ? ui.leadFor(lang.nativeName) : (lang.heroLead ?? ui.leadFor(lang.name)), style: const TextStyle(fontSize: 15.5, height: 1.5)),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: ui.search),
            onChanged: (v) => setState(() => _q = v),
          ),
          const SizedBox(height: 18),
          Text(ui.choose, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Brand.heading)),
          const SizedBox(height: 12),
          if (cards.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(ui.none))),
          ...cards,
        ],
      ),
    );
  }
}

IconData _iconFor(String? bi) => switch (bi) {
      'bi-stars' => Icons.auto_awesome,
      'bi-shield-shaded' => Icons.shield,
      'bi-trophy' => Icons.emoji_events,
      'bi-heart' => Icons.favorite,
      'bi-lightning-charge' => Icons.bolt,
      'bi-book' => Icons.menu_book,
      'bi-patch-check-fill' => Icons.verified,
      'bi-fire' => Icons.local_fire_department,
      'bi-globe-americas' => Icons.public,
      _ => Icons.auto_stories,
    };

class _BookCard extends StatelessWidget {
  final Book book;
  final List<Lesson> lessons, shown;
  final bool forceOpen;
  final Language lang;
  final Set<String> done;
  final Future<void> Function() onBack;   // refreshes the ticks when coming back from a lesson
  const _BookCard({required this.book, required this.lessons, required this.shown, required this.forceOpen, required this.lang, required this.done, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final a = Brand.hex(book.colorA), b = Brand.hex(book.colorB, a);
    final ui = UiStrings.of(lang.code);
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [a, b], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: Row(children: [
            Text('${book.bookNo}', style: TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(.9), height: 1)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ui.bookLabel(book.bookNo), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Directionality(textDirection: lang.textDirection, child: Text(book.mainTitle, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800, height: 1.3))),
              ]),
            ),
            Icon(_iconFor(book.icon), color: Colors.white.withOpacity(.85), size: 30),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Brand.bg, borderRadius: BorderRadius.circular(20)),
              child: Text(ui.completedLabel(lessons.where((l) => done.contains('${l.bookNo}:${l.lessonNo}')).length, lessons.length), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            if (lessons.isNotEmpty)
              TextButton.icon(
                onPressed: () => _open(context, _resume),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(_resume.lessonNo == lessons.first.lessonNo && !done.contains('${lessons.first.bookNo}:${lessons.first.lessonNo}') ? ui.startLabel(_resume.lessonNo) : ui.continueLabel(_resume.lessonNo)),
                style: TextButton.styleFrom(foregroundColor: Brand.accent),
              ),
          ]),
        ),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey('book-${book.bookNo}-${forceOpen}'),
            initiallyExpanded: forceOpen,
            title: Text(ui.browseLabel(lessons.length), style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
            children: [
              for (final l in shown)
                ListTile(
                  dense: true,
                  trailing: done.contains('${l.bookNo}:${l.lessonNo}') ? const Icon(Icons.check_circle, color: Color(0xFF198754)) : null,
                  leading: CircleAvatar(radius: 14, backgroundColor: a.withOpacity(.12), child: Text('${l.lessonNo}', style: TextStyle(fontSize: 12, color: a, fontWeight: FontWeight.w700))),
                  title: Directionality(textDirection: lang.textDirection, child: Text(l.titleNative, style: const TextStyle(fontSize: 16, height: 1.35))),
                  onTap: () => _open(context, l),
                ),
            ],
          ),
        ),
        _WorkbookDownload(book: book, lang: lang, color: a),
      ]),
    );
  }

  /// first lesson of the book that is not completed yet (or the first one when all are done)
  Lesson get _resume => lessons.firstWhere((l) => !done.contains('${l.bookNo}:${l.lessonNo}'), orElse: () => lessons.first);

  Future<void> _open(BuildContext context, Lesson l) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => LessonScreen(language: lang, book: book, lessons: lessons, index: lessons.indexOf(l))));
    await onBack();
  }
}

/// "Book-N-Student-Workbook" row under "Browse all lessons": downloads the combined student workbook PDF of the book
/// straight to the phone (Downloads / ABBA Sunday School) and opens it - the browser is not used.
class _WorkbookDownload extends StatefulWidget {
  final Book book;
  final Language lang;
  final Color color;
  const _WorkbookDownload({required this.book, required this.lang, required this.color});
  @override
  State<_WorkbookDownload> createState() => _WorkbookDownloadState();
}

class _WorkbookDownloadState extends State<_WorkbookDownload> {
  bool _busy = false;
  double _progress = 0;

  String get _name => 'Book-${widget.book.bookNo}-Student-Workbook';

  Future<void> _download() async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final url = '${AppConfig.siteBase}/Resources/SundaySchool_Lessons/${widget.lang.webFolder}/${widget.book.folder}/$_name.pdf';
    setState(() { _busy = true; _progress = 0; });
    try {
      final r = await PdfDownloader.download(url, '${widget.lang.webFolder}-$_name.pdf', onProgress: (v) { if (mounted) setState(() => _progress = v); });
      messenger.showSnackBar(SnackBar(content: Text(r.inDownloads ? 'Saved in Downloads / ${PdfDownloader.folderName}' : 'Downloaded')));
      await OpenFilex.open(r.path, type: 'application/pdf');
    } on PdfNotAvailable {
      messenger.showSnackBar(const SnackBar(content: Text('This workbook is not available yet.')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not download. Check your internet connection.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _busy ? null : _download,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: c.withValues(alpha: 0.05),
              border: Border.all(color: c, width: 1.4),
            ),
            child: Row(children: [
              Icon(Icons.picture_as_pdf_outlined, color: c),
              const SizedBox(width: 10),
              Expanded(child: Text(_name, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c))),
              _busy
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: c, value: _progress > 0 ? _progress : null))
                  : Icon(Icons.download_rounded, color: c),
            ]),
          ),
        ),
      ),
    );
  }
}
