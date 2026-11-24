import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';

/// User choices stored on the phone: theme colour, font size and profile.
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  /// name -> colour offered in Settings
  static const palette = <String, Color>{
    'Red': Color(0xFFDC3545),
    'Blue': Color(0xFF0D6EFD),
    'Green': Color(0xFF198754),
    'Purple': Color(0xFF6F42C1),
    'Orange': Color(0xFFFD7E14),
    'Teal': Color(0xFF0AA2C0),
    'Pink': Color(0xFFD63384),
    'Brown': Color(0xFF795548),
  };
  static const minScale = 0.85, maxScale = 1.5;

  double fontScale = 1.0;
  String name = '', email = '', mobile = '';

  /// Weekly "prepare for Sunday class" reminder (weekday: 1=Monday ... 7=Sunday).
  bool alertOn = false;
  int alertWeekday = DateTime.saturday, alertHour = 18, alertMinute = 0;
  String lastLang = 'hi';

  /// Languages the user pinned to the top of the lessons list and of the songs list (language codes, in the order pinned).
  List<String> pinnedLessons = [], pinnedSongs = [];

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final c = p.getInt('theme_color');
      if (c != null) Brand.accent = Color(c);
      fontScale = (p.getDouble('font_scale') ?? 1.0).clamp(minScale, maxScale);
      name = p.getString('profile_name') ?? '';
      email = p.getString('profile_email') ?? '';
      mobile = p.getString('profile_mobile') ?? '';
      alertOn = p.getBool('alert_on') ?? false;
      alertWeekday = p.getInt('alert_weekday') ?? DateTime.saturday;
      alertHour = p.getInt('alert_hour') ?? 18;
      alertMinute = p.getInt('alert_minute') ?? 0;
      lastLang = p.getString('last_lang') ?? 'hi';
      pinnedLessons = p.getStringList('pinned_lessons') ?? [];
      pinnedSongs = p.getStringList('pinned_songs') ?? [];
    } catch (_) {/* defaults */}
  }

  List<String> pinsFor(bool songs) => songs ? pinnedSongs : pinnedLessons;

  bool isPinned(bool songs, String code) => pinsFor(songs).contains(code);

  /// Pins (or unpins) a language for the lessons list or the songs list.
  Future<void> togglePin(bool songs, String code) async {
    final l = pinsFor(songs);
    l.contains(code) ? l.remove(code) : l.add(code);
    notifyListeners();
    try { (await SharedPreferences.getInstance()).setStringList(songs ? 'pinned_songs' : 'pinned_lessons', l); } catch (_) {}
  }

  Future<void> setColor(Color c) async {
    Brand.accent = c;
    notifyListeners();
    _rebuildEverything();
    try { (await SharedPreferences.getInstance()).setInt('theme_color', c.value); } catch (_) {}
  }

  Future<void> setFontScale(double v) async {
    fontScale = v.clamp(minScale, maxScale);
    notifyListeners();
    try { (await SharedPreferences.getInstance()).setDouble('font_scale', fontScale); } catch (_) {}
  }

  Future<void> resetLook() async {
    fontScale = 1.0;
    await setColor(Brand.defaultAccent);
    try { (await SharedPreferences.getInstance()).setDouble('font_scale', 1.0); } catch (_) {}
    notifyListeners();
  }

  Future<void> setAlert({bool? on, int? weekday, int? hour, int? minute}) async {
    alertOn = on ?? alertOn;
    alertWeekday = weekday ?? alertWeekday;
    alertHour = hour ?? alertHour;
    alertMinute = minute ?? alertMinute;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool('alert_on', alertOn);
      await p.setInt('alert_weekday', alertWeekday);
      await p.setInt('alert_hour', alertHour);
      await p.setInt('alert_minute', alertMinute);
    } catch (_) {}
  }

  Future<void> setLastLang(String code) async {
    lastLang = code;
    try { (await SharedPreferences.getInstance()).setString('last_lang', code); } catch (_) {}
  }

  Future<void> saveProfile({required String name, required String email, required String mobile}) async {
    this.name = name.trim();
    this.email = email.trim();
    this.mobile = mobile.trim();
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('profile_name', this.name);
      await p.setString('profile_email', this.email);
      await p.setString('profile_mobile', this.mobile);
    } catch (_) {}
  }

  /// Screens read Brand.accent directly, so after a colour change every open screen is asked to rebuild.
  void _rebuildEverything() {
    void visit(Element e) {
      e.markNeedsBuild();
      e.visitChildren(visit);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => WidgetsBinding.instance.rootElement?.visitChildren(visit));
  }
}
