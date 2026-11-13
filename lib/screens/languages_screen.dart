import 'package:flutter/material.dart';

import '../data/local_db.dart';
import '../data/models.dart';
import '../theme.dart';
import '../settings.dart';
import 'app_drawer.dart';
import 'language_home_screen.dart';
import 'songs_screen.dart';

/// First screen: the list of languages (same cards as the website's lessons page).
class LanguagesScreen extends StatefulWidget {
  /// false = Welcome screen (choose a language for lessons); true = choose a language for songs.
  final bool forSongs;
  const LanguagesScreen({super.key, this.forSongs = false});
  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  late Future<List<Language>> _langs = LocalDb.instance.languages();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.forSongs ? null : const AppDrawer(),
      appBar: AppBar(
        title: widget.forSongs ? const Text('Songs') : Row(children: [
          Image.asset('assets/logo.png', height: 30, errorBuilder: (_, __, ___) => Icon(Icons.child_care, color: Brand.accent)),
          const SizedBox(width: 10),
          const Text('ABBA Sunday School'),
        ]),
      ),
      body: FutureBuilder<List<Language>>(
        future: _langs,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final langs = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                alignment: Alignment.centerLeft,
                child: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Icon(Icons.menu_book, size: 18, color: Brand.accent),
                  Text('Christian Sunday School', style: TextStyle(color: Brand.accent, fontWeight: FontWeight.w600)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: Text(
                    widget.forSongs
                        ? 'Choose a language\nfor songs'
                        : (AppSettings.instance.name.isEmpty ? 'Welcome!' : 'Welcome, ${AppSettings.instance.name}!'),
                    style: const TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w800, color: Brand.heading)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                child: Text(
                    widget.forSongs
                        ? 'Pick a language to see its children\'s songs.'
                        : 'Choose a language for the Bible lessons. Lessons are saved on your phone, so you can read them without internet.',
                    style: const TextStyle(fontSize: 15.5, height: 1.5)),
              ),
              for (final l in langs)
                Padding(padding: const EdgeInsets.only(bottom: 14), child: _LanguageCard(l, onTap: () => _open(l), comingSoon: !l.active)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _open(Language l) async {
    if (!l.active) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l.name} lessons are coming soon.')));
      return;
    }
    await Navigator.push(context, MaterialPageRoute(builder: (_) => widget.forSongs ? SongsScreen(language: l) : LanguageHomeScreen(language: l)));
    if (mounted) setState(() => _langs = LocalDb.instance.languages());
  }
}

class _LanguageCard extends StatelessWidget {
  final Language lang;
  final VoidCallback onTap;
  final bool comingSoon;
  const _LanguageCard(this.lang, {required this.onTap, this.comingSoon = false});

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: comingSoon ? Colors.grey.shade400 : Brand.accent, shape: BoxShape.circle),
                child: Text(lang.glyph, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(lang.nativeName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Brand.heading)),
                  const SizedBox(height: 2),
                  Text(comingSoon ? 'Coming soon' : 'View all ${lang.name}', style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600)),
                ]),
              ),
              Icon(comingSoon ? Icons.schedule : Icons.arrow_circle_right_outlined, color: comingSoon ? Colors.grey.shade500 : Brand.accent, size: 30),
            ]),
          ),
        ),
      );
}
