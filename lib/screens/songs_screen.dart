import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/local_db.dart';
import '../data/models.dart';
import '../data/repository.dart';
import '../theme.dart';
import 'app_drawer.dart';

/// Children's songs of a language: searchable list.
class SongsScreen extends StatefulWidget {
  final Language language;
  const SongsScreen({super.key, required this.language});
  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  List<Song> _songs = [];
  bool _loading = true;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var s = await LocalDb.instance.songs(widget.language.code);
    if (s.isEmpty) {
      try { await Repository.instance.syncLanguage(widget.language.code); s = await LocalDb.instance.songs(widget.language.code); } catch (_) {}
    }
    if (mounted) setState(() { _songs = s; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final list = q.isEmpty ? _songs : _songs.where((s) => s.titleNative.toLowerCase().contains(q) || (s.titleEn ?? '').toLowerCase().contains(q) || '${s.songNo}' == q).toList();
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leadingWidth: AppBarLeading.width,
        leading: const AppBarLeading(),
        title: Text('${widget.language.name} Songs'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No songs for this language yet. (If songs exist, connect to the internet once to download them.)', textAlign: TextAlign.center)))
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search songs...'), onChanged: (v) => setState(() => _q = v)),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final s = list[i];
                        return ListTile(
                          leading: CircleAvatar(backgroundColor: Brand.accent.withOpacity(.1), child: Text('${s.songNo}', style: TextStyle(color: Brand.accent, fontWeight: FontWeight.w700, fontSize: 13))),
                          title: Text(s.titleNative, style: const TextStyle(fontSize: 16.5, height: 1.3)),
                          subtitle: s.titleEn == null ? null : Text(s.titleEn!),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SongScreen(language: widget.language, songs: _songs, index: _songs.indexOf(s)))),
                        );
                      },
                    ),
                  ),
                ]),
    );
  }
}

/// One song with a toggle between the native script and English letters (like the website).
class SongScreen extends StatefulWidget {
  final Language language;
  final List<Song> songs;
  final int index;
  const SongScreen({super.key, required this.language, required this.songs, required this.index});
  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  late int _i = widget.index;
  bool _english = false;
  Song get s => widget.songs[_i];

  /// Opens the song's own video when a link is stored; otherwise a YouTube search for the song.
  Future<void> _youtube() async {
    final link = s.youtubeUrl;
    final url = (link != null && link.isNotEmpty)
        ? link
        : 'https://www.youtube.com/results?search_query=${Uri.encodeQueryComponent('${s.titleNative} ${widget.language.name} children Sunday school song')}';
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open YouTube.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasEn = (s.lyricsEn ?? '').trim().isNotEmpty;
    final showEn = _english && hasEn;
    final lyrics = showEn ? s.lyricsEn! : s.lyricsNative;
    final title = showEn ? (s.titleEn ?? s.titleNative) : s.titleNative;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leadingWidth: AppBarLeading.width,
        leading: const AppBarLeading(),
        title: Text('Song ${s.songNo}', style: const TextStyle(fontSize: 18)),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
        if (widget.language.name.trim().toLowerCase() != 'english') Row(children: [
          SegmentedButton<bool>(
            segments: [ButtonSegment(value: false, label: Text(widget.language.name)), const ButtonSegment(value: true, label: Text('English'))],
            selected: {_english},
            onSelectionChanged: (v) => setState(() => _english = v.first),
            style: SegmentedButton.styleFrom(selectedBackgroundColor: Brand.accent, selectedForegroundColor: Colors.white),
          ),
        ]),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Brand.heading, height: 1.3)),
        const SizedBox(height: 14),
        SelectableText(lyrics, style: const TextStyle(fontSize: 19, height: 1.8, color: Brand.text)),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _youtube,
          icon: const Icon(Icons.play_circle_fill),
          label: Text(s.youtubeUrl != null && s.youtubeUrl!.isNotEmpty ? 'Watch on YouTube' : 'Find on YouTube'),
        ),
        const SizedBox(height: 12),
        Row(children: [
          OutlinedButton.icon(onPressed: () => Share.share('$title\n\n$lyrics'), icon: const Icon(Icons.share, size: 18), label: const Text('Share')),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: '$title\n\n$lyrics'));
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy'),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          TextButton.icon(onPressed: _i > 0 ? () => setState(() => _i--) : null, icon: const Icon(Icons.chevron_left), label: const Text('Previous')),
          const Spacer(),
          TextButton.icon(onPressed: _i < widget.songs.length - 1 ? () => setState(() => _i++) : null, icon: const Text('Next'), label: const Icon(Icons.chevron_right)),
        ]),
      ]),
    );
  }
}
