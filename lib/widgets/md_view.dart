import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../theme.dart';

/// Renders the lesson text (light Markdown stored in the database) with a decorated look.
///
/// The lesson text mostly uses plain bold lines instead of real headings, so the text is split into
/// blocks and each kind of block gets its own style:
///   **Heading**            -> section heading with an accent bar
///   **1. Question**        -> numbered badge heading
///   **Label:** text        -> tinted callout card (Objective, Scripture, Memory verse ...)
///   1. numbered point      -> round number badge + text
///   short line / "text:"   -> sub-heading
///   | table |              -> rounded, scrollable table
///   anything else          -> normal paragraph / list
class MdView extends StatelessWidget {
  final String data;
  const MdView(this.data, {super.key});

  static final _blockSplit = RegExp(r'\n\s*\n');
  static final _boldOnly = RegExp(r'^\*\*([^*]+)\*\*\s*$');
  static final _numberedHeading = RegExp(r'^(\d+)[.)]\s*(.+)$', dotAll: true);
  static final _labelLine = RegExp(r'^\*\*([^*]{1,70}?[:：])\s*\*\*\s*(.+)$', dotAll: true);
  static final _numberedPoint = RegExp(r'^(\d+)\.\s+(.+)$', dotAll: true);

  static const _calloutIcons = [Icons.flag_rounded, Icons.menu_book_rounded, Icons.auto_awesome_rounded, Icons.lightbulb_rounded];

  @override
  Widget build(BuildContext context) {
    final blocks = data.trim().split(_blockSplit).map((b) => b.trim()).where((b) => b.isNotEmpty).toList();
    final children = <Widget>[];
    var callouts = 0;
    for (final b in blocks) {
      final oneLine = !b.contains('\n');
      Match? m;
      if (oneLine && (m = _boldOnly.firstMatch(b)) != null) {
        final inner = m!.group(1)!.trim();
        final q = _numberedHeading.firstMatch(inner);
        children.add(q != null ? _QuestionHeading(q.group(1)!, q.group(2)!) : _SectionHeading(inner));
      } else if ((m = _labelLine.firstMatch(b)) != null) {
        children.add(_Callout(
          label: m!.group(1)!.trim().replaceAll(RegExp(r'[:：]$'), ''),
          body: m.group(2)!.trim(),
          icon: callouts < _calloutIcons.length ? _calloutIcons[callouts] : Icons.star_rounded,
        ));
        callouts++;
      } else if (b.startsWith('|')) {
        children.add(_TableBlock(b));
      } else if ((m = _numberedPoint.firstMatch(b)) != null) {
        children.add(_NumberedPoint(m!.group(1)!, m.group(2)!.trim()));
      } else if (oneLine && _looksLikeSubHeading(b)) {
        children.add(_SubHeading(b.replaceAll(RegExp(r'\\_'), '_')));
      } else {
        children.add(Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: _md(context, b)));
      }
    }
    return SelectionArea(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children));
  }

  static bool _looksLikeSubHeading(String s) {
    if (s.length > 55) return false;
    if (RegExp(r'^[-*>|#\d`_\\]').hasMatch(s) || s.contains('**')) return false;
    return !RegExp(r'[।.?!”"]$').hasMatch(s);
  }
}

/// Markdown paragraph/list in the app style.
Widget _md(BuildContext context, String text, {double? size}) {
  final base = Theme.of(context).textTheme;
  final a = Brand.accent;
  final body = base.bodyLarge!.copyWith(fontSize: size ?? 16.5, height: 1.7, color: Brand.text);
  return MarkdownBody(
    data: text,
    extensionSet: md.ExtensionSet.gitHubFlavored,
    bulletBuilder: (p) => p.style == BulletStyle.unorderedList
        ? Padding(padding: const EdgeInsets.only(top: 9), child: Icon(Icons.circle, size: 8, color: a))
        : Text('${p.index + 1}.', style: body.copyWith(fontWeight: FontWeight.w800, color: a)),
    styleSheet: MarkdownStyleSheet(
      p: body,
      pPadding: const EdgeInsets.only(bottom: 2),
      strong: body.copyWith(fontWeight: FontWeight.w800, color: Brand.heading),
      em: body.copyWith(fontStyle: FontStyle.italic, color: Brand.accentDark),
      h1: base.headlineSmall!.copyWith(color: a, fontWeight: FontWeight.w800),
      h2: base.titleLarge!.copyWith(color: a, fontWeight: FontWeight.w800, height: 1.4),
      h3: base.titleMedium!.copyWith(color: a, fontWeight: FontWeight.w700, height: 1.4),
      h4: base.titleSmall!.copyWith(color: Brand.heading, fontWeight: FontWeight.w700),
      listBullet: body,
      listIndent: 22,
      blockquote: body.copyWith(fontStyle: FontStyle.italic, color: Brand.heading),
      blockquotePadding: const EdgeInsets.all(14),
      blockquoteDecoration: BoxDecoration(
        color: a.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: a.withValues(alpha: 0.25)),
      ),
      tableBody: body.copyWith(fontSize: 15.5, height: 1.45),
      tableHead: body.copyWith(fontSize: 15.5, fontWeight: FontWeight.w800, color: a),
      tableBorder: TableBorder.all(color: a.withValues(alpha: 0.25), width: 1),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      tableColumnWidth: const IntrinsicColumnWidth(),
      blockSpacing: 8,
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  final String text;
  const _SectionHeading(this.text);
  @override
  Widget build(BuildContext context) {
    final a = Brand.accent;
    return Container(
      margin: const EdgeInsets.only(top: 22, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [a.withValues(alpha: 0.16), a.withValues(alpha: 0.02)]),
      ),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 6, decoration: BoxDecoration(color: a, borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
              child: Text(text, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.4, color: Brand.accentDark)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _QuestionHeading extends StatelessWidget {
  final String no, text;
  const _QuestionHeading(this.no, this.text);
  @override
  Widget build(BuildContext context) {
    final a = Brand.accent;
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34, alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [a, Brand.accentDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [BoxShadow(color: a.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: Text(no, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.4, color: Brand.heading)),
          ),
        ),
      ]),
    );
  }
}

class _Callout extends StatelessWidget {
  final String label, body;
  final IconData icon;
  const _Callout({required this.label, required this.body, required this.icon});
  @override
  Widget build(BuildContext context) {
    final a = Brand.accent;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: a.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: a.withValues(alpha: 0.28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: a, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Brand.accentDark))),
        ]),
        const SizedBox(height: 8),
        _md(context, body),
      ]),
    );
  }
}

class _NumberedPoint extends StatelessWidget {
  final String no, text;
  const _NumberedPoint(this.no, this.text);
  @override
  Widget build(BuildContext context) {
    final a = Brand.accent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 3),
          width: 28, height: 28, alignment: Alignment.center,
          decoration: BoxDecoration(color: a.withValues(alpha: 0.12), shape: BoxShape.circle, border: Border.all(color: a, width: 1.5)),
          child: Text(no, style: TextStyle(color: Brand.accentDark, fontWeight: FontWeight.w800, fontSize: 13.5)),
        ),
        const SizedBox(width: 12),
        Expanded(child: _md(context, text)),
      ]),
    );
  }
}

class _SubHeading extends StatelessWidget {
  final String text;
  const _SubHeading(this.text);
  @override
  Widget build(BuildContext context) {
    final a = Brand.accent;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 3), child: Icon(Icons.bookmark_rounded, size: 18, color: a)),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, height: 1.4, color: Brand.accentDark))),
      ]),
    );
  }
}

class _TableBlock extends StatelessWidget {
  final String text;
  const _TableBlock(this.text);

  /// Splits a markdown table into rows of cells (drops the |---| separator row).
  static List<List<String>> _rows(String t) {
    final rows = <List<String>>[];
    for (final line in t.split('\n')) {
      final l = line.trim();
      if (!l.startsWith('|')) continue;
      if (RegExp(r'^\|[\s:|-]+\|?$').hasMatch(l)) continue;   // separator row
      var inner = l.substring(1);
      if (inner.endsWith('|') && !inner.endsWith(r'\|')) inner = inner.substring(0, inner.length - 1);
      rows.add(inner.split(RegExp(r'(?<!\\)\|')).map((c) => c.trim()).toList());
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final a = Brand.accent;
    final rows = _rows(text);
    // Two-column "label | text" tables (Aim / Scripture Reading / Memory Verse): stack label above text so
    // everything wraps inside the screen instead of running off the side.
    final keyValue = rows.isNotEmpty &&
        rows.every((r) => r.length == 2 && r[0].startsWith('**') && r[0].length <= 60);
    if (keyValue) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: a.withValues(alpha: 0.3)),
          color: a.withValues(alpha: 0.04),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: a.withValues(alpha: 0.2)))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(rows[i][0].replaceAll('**', '').trim(), style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: a, letterSpacing: 0.3)),
                const SizedBox(height: 2),
                _md(context, rows[i][1]),
              ]),
            ),
        ]),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: a.withValues(alpha: 0.3)),
        color: a.withValues(alpha: 0.03),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: _md(context, text, size: 15.5)),
    );
  }
}
