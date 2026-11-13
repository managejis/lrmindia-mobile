import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../config.dart';
import '../data/local_db.dart';
import '../data/models.dart';
import '../data/pdf_downloader.dart';
import '../notifications.dart';
import '../theme.dart';
import '../widgets/md_view.dart';
import 'app_drawer.dart';

/// One lesson: five tabs (Teacher's Guide, Teacher Workbook, Student Workbook, Crafts, Games),
/// previous / next lesson, and a button to download the student workbook PDF from lrmindia.org.
class LessonScreen extends StatefulWidget {
  final Language language;
  final Book book;
  final List<Lesson> lessons;   // all lessons of this book
  final int index;
  const LessonScreen({super.key, required this.language, required this.book, required this.lessons, required this.index});
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> with TickerProviderStateMixin {
  late int _i = widget.index;
  Map<String, String> _texts = {};
  bool _loading = true;
  bool _done = false;
  late final TabController _tabs = TabController(length: LessonKind.values.length, vsync: this);

  Lesson get lesson => widget.lessons[_i];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final t = await LocalDb.instance.contents(widget.language.code, widget.book.bookNo, lesson.lessonNo);
    final done = (await LocalDb.instance.completed(widget.language.code)).contains('${widget.book.bookNo}:${lesson.lessonNo}');
    if (mounted) setState(() { _texts = t; _done = done; _loading = false; });
  }

  Future<void> _toggleDone() async {
    final v = !_done;
    await LocalDb.instance.setCompleted(widget.language.code, widget.book.bookNo, lesson.lessonNo, v);
    if (mounted) setState(() => _done = v);
    Notifier.refresh();     // the Sunday alert names the next lesson that is not completed
    if (mounted && v) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lesson ${lesson.lessonNo} marked as completed')));
    }
  }

  void _go(int to) {
    if (to < 0 || to >= widget.lessons.length) return;
    setState(() => _i = to);
    _load();
  }

  String get _pdfUrl => AppConfig.workbookPdfUrl(widget.language.webFolder, widget.book.folder, lesson.lessonNo);

  bool _downloading = false;
  double _progress = 0;

  /// Downloads the student workbook PDF to the phone (Downloads/ABBA Sunday School) and opens it.
  Future<void> _downloadPdf() async {
    if (_downloading) return;
    final messenger = ScaffoldMessenger.of(context);
    final fileName = '${widget.language.webFolder}-${widget.book.folder}-lesson-${lesson.lessonNo.toString().padLeft(2, '0')}-student-workbook.pdf';
    setState(() { _downloading = true; _progress = 0; });
    try {
      final r = await PdfDownloader.download(_pdfUrl, fileName, onProgress: (v) { if (mounted) setState(() => _progress = v); });
      messenger.showSnackBar(SnackBar(content: Text(r.inDownloads ? 'Saved in Downloads / ${PdfDownloader.folderName}' : 'Workbook downloaded')));
      await OpenFilex.open(r.path, type: 'application/pdf');
    } on PdfNotAvailable {
      messenger.showSnackBar(const SnackBar(content: Text('This workbook PDF is not available yet.')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Could not download the workbook. Check your internet connection.')));
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  static const _tabIcons = [Icons.menu_book_rounded, Icons.fact_check_rounded, Icons.edit_note_rounded, Icons.palette_rounded, Icons.sports_esports_rounded];
  static const _tabLabels = ['Guide', 'Answers', 'Student', 'Crafts', 'Games'];

  @override
  Widget build(BuildContext context) {
    final prev = _i > 0, next = _i < widget.lessons.length - 1;
    const navStyle = ButtonStyle(
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
      minimumSize: WidgetStatePropertyAll(Size(0, 40)),
      visualDensity: VisualDensity.compact,
    );
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leadingWidth: AppBarLeading.width,
        leading: Builder(builder: (ctx) => const AppBarLeading()),
        titleSpacing: 0,
        title: Text('Lesson ${lesson.lessonNo}', style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton.icon(
            style: navStyle,
            onPressed: prev ? () => _go(_i - 1) : null,
            icon: const Icon(Icons.chevron_left, size: 20),
            label: const Text('Previous', style: TextStyle(fontSize: 13)),
          ),
          TextButton.icon(
            style: navStyle,
            onPressed: next ? () => _go(_i + 1) : null,
            icon: const Text('Next', style: TextStyle(fontSize: 13)),
            label: const Icon(Icons.chevron_right, size: 20),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(controller: _tabs, children: [for (final k in LessonKind.values) _panel(k)]),
      bottomNavigationBar: AnimatedBuilder(
        animation: _tabs.animation!,
        builder: (_, __) => NavigationBar(
          height: 66,
          backgroundColor: Colors.white,
          indicatorColor: Brand.accent.withValues(alpha: 0.14),
          selectedIndex: _tabs.index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) => _tabs.animateTo(i),
          destinations: [
            for (var i = 0; i < _tabLabels.length; i++)
              NavigationDestination(
                icon: Icon(_tabIcons[i], color: Brand.text),
                selectedIcon: Icon(_tabIcons[i], color: Brand.accent),
                label: _tabLabels[i],
                tooltip: LessonKind.values[i].label,
              ),
          ],
        ),
      ),
    );
  }

  /// Decorated lesson heading: gradient banner with a "LESSON n" chip, the title at body-text size, and the done toggle.
  Widget _banner() {
    final a = Brand.accent;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [a, Brand.accentDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: a.withValues(alpha: 0.30), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Stack(children: [
        Positioned(right: -28, top: -28, child: Container(width: 110, height: 110, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.10)))),
        Positioned(right: 36, bottom: -34, child: Container(width: 76, height: 76, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)))),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(20)),
                child: Text('LESSON ${lesson.lessonNo}', style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              ),
              const Spacer(),
              _doneButton(),
            ]),
            const SizedBox(height: 10),
            Text(lesson.titleNative, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: Colors.white, height: 1.45)),
            if (lesson.titleEn != null && lesson.titleEn != lesson.titleNative)
              Padding(padding: const EdgeInsets.only(top: 3), child: Text(lesson.titleEn!, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)))),
          ]),
        ),
      ]),
    );
  }

  Widget _doneButton() => Tooltip(
        message: _done ? 'Completed - tap to undo' : 'Mark this lesson as completed',
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _toggleDone,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _done ? const Color(0xFF198754) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_done ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: _done ? Colors.white : Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(_done ? 'Completed' : 'Mark done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _done ? Colors.white : Colors.grey.shade700)),
            ]),
          ),
        ),
      );

  Widget _panel(LessonKind k) {
    final text = _texts[k.key];
    final isStudent = k == LessonKind.workbookStudent;
    return ListView(
      key: PageStorageKey('${lesson.lessonNo}-${k.key}'),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      children: [
        _banner(),
        if (isStudent)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFFF4F5), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF5C2C7))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Printable workbook for students', style: TextStyle(fontWeight: FontWeight.w700, color: Brand.heading)),
              const SizedBox(height: 4),
              const Text('Download the PDF with the pictures to your phone to print or share. (Needs internet the first time.)', style: TextStyle(fontSize: 13.5)),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _downloading ? null : _downloadPdf,
                icon: _downloading ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, value: _progress > 0 ? _progress : null)) : const Icon(Icons.download),
                label: Text(_downloading ? 'Downloading...' : 'Download PDF'),
              ),
            ]),
          ),
        if (text == null || text.trim().isEmpty)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Nothing here for this lesson.')))
        else
          MdView(text),
        if (k == LessonKind.teachersGuide && text != null)
          Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Container(
              padding: const EdgeInsets.only(top: 14),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Text('Copyright © Global Recordings Network. Used by permission.', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
            ),
          ),
      ],
    );
  }
}
