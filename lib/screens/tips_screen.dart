import 'package:flutter/material.dart';

import '../data/tips_content.dart';
import '../settings.dart';
import '../theme.dart';
import 'app_drawer.dart';

/// Tips for teachers: how to run a Sunday school class using the ABBA Sunday School material.
/// A drop-down at the top switches the page between the 11 languages.
class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});
  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  static const _icons = <IconData>[
    Icons.event_available_outlined,
    Icons.waving_hand_outlined,
    Icons.flag_outlined,
    Icons.menu_book_outlined,
    Icons.favorite_border,
    Icons.record_voice_over_outlined,
    Icons.edit_note,
    Icons.palette_outlined,
    Icons.sports_esports_outlined,
    Icons.check_circle_outline,
  ];

  late String _code = tipLanguages.any((l) => l.$1 == AppSettings.instance.lastLang) ? AppSettings.instance.lastLang : 'en';

  @override
  Widget build(BuildContext context) {
    final t = tipsFor(_code);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leadingWidth: AppBarLeading.width,
        leading: const AppBarLeading(),
        title: const Text('Tips'),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
        // language drop-down (all 11 languages)
        DropdownButtonFormField<String>(
          value: _code,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Language',
            prefixIcon: Icon(Icons.language, color: Brand.accent),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          items: [for (final l in tipLanguages) DropdownMenuItem(value: l.$1, child: Text(l.$2, style: const TextStyle(fontSize: 16)))],
          onChanged: (v) {
            if (v != null) setState(() => _code = v);
          },
        ),
        const SizedBox(height: 14),
        Directionality(
          textDirection: _code == 'ur' ? TextDirection.rtl : TextDirection.ltr,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: [Brand.accent, Brand.accentDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.3)),
                const SizedBox(height: 6),
                Text(t.intro, style: const TextStyle(color: Colors.white, fontSize: 14.5, height: 1.5)),
              ]),
            ),
            const SizedBox(height: 18),
            Text(t.flowHeading, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Brand.heading)),
            const SizedBox(height: 10),
            for (var i = 0; i < t.steps.length; i++) _stepCard(i + 1, _icons[i % _icons.length], t.steps[i]),
            const SizedBox(height: 10),
            Text(t.generalHeading, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Brand.heading)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              decoration: BoxDecoration(
                color: Brand.accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Brand.accent.withValues(alpha: 0.25)),
              ),
              child: Column(children: [for (final g in t.general) _bullet(g)]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _stepCard(int no, IconData icon, TipStep s) {
    final a = Brand.accent;
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 34, height: 34, alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [a, Brand.accentDark])),
              child: Text('$no', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(s.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Brand.heading, height: 1.3))),
            Icon(icon, color: a),
          ]),
          const SizedBox(height: 8),
          for (final p in s.points) _bullet(p),
        ]),
      ),
    );
  }

  Widget _bullet(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsetsDirectional.only(top: 8, end: 10), child: Icon(Icons.circle, size: 7, color: Brand.accent)),
          Expanded(child: Text(t, style: const TextStyle(fontSize: 15, height: 1.55, color: Brand.text))),
        ]),
      );
}
