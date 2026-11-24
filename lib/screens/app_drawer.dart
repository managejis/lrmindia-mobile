import 'package:flutter/material.dart';

import '../settings.dart';
import '../theme.dart';
import 'feedback_screen.dart';
import 'languages_screen.dart';
import 'lrm_india_screen.dart';
import 'manageji_screen.dart';
import 'privacy_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'tips_screen.dart';

/// The burger menu: Lessons, Songs, Tips, Profile, Settings, LRM India, ManageJi, Feedback, Privacy Policy.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, Widget screen) {
    Navigator.pop(context);   // close the drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.instance;
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            color: Brand.accent,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Image.asset('assets/app_logo.png', height: 40, errorBuilder: (_, __, ___) => Icon(Icons.child_care, color: Brand.accent, size: 40)),
              ),
              const SizedBox(height: 14),
              const Text('ABBA Sunday School', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(s.name.isEmpty ? 'Bible lessons & songs for children' : 'Hello, ${s.name}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
            ]),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
              _item(context, Icons.menu_book_outlined, 'Lessons', () {
                Navigator.pop(context);
                Navigator.of(context).popUntil((r) => r.isFirst);   // back to the welcome / language list
              }),
              _item(context, Icons.music_note_outlined, 'Songs', () => _go(context, const LanguagesScreen(forSongs: true))),
              _item(context, Icons.lightbulb_outline, 'Tips', () => _go(context, const TipsScreen())),
              const Divider(),
              _item(context, Icons.person_outline, 'Profile', () => _go(context, const ProfileScreen())),
              _item(context, Icons.settings_outlined, 'Settings', () => _go(context, const SettingsScreen())),
              const Divider(),
              _item(context, Icons.church_outlined, 'LRM India', () => _go(context, const LrmIndiaScreen())),
              _item(context, Icons.code_rounded, 'ManageJi', () => _go(context, const ManageJiScreen())),
              _item(context, Icons.feedback_outlined, 'Feedback', () => _go(context, const FeedbackScreen())),
              _item(context, Icons.privacy_tip_outlined, 'Privacy Policy', () => _go(context, const PrivacyScreen())),
            ]),
          ),
          Padding(padding: const EdgeInsets.all(12), child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))),
        ]),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, VoidCallback onTap) => ListTile(
        leading: Icon(icon, color: Brand.accent),
        title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Brand.heading)),
        onTap: onTap,
      );
}

/// Left side of the top bar on lesson / song pages: burger menu first, then the back arrow.
/// The Scaffold using it must have `drawer: const AppDrawer()`. Pair with `leadingWidth: AppBarLeading.width`.
class AppBarLeading extends StatelessWidget {
  static const double width = 104;
  const AppBarLeading({super.key});

  @override
  Widget build(BuildContext context) => Row(children: [
        IconButton(tooltip: 'Menu', icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        IconButton(tooltip: 'Back', icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
      ]);
}
