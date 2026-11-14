import 'package:flutter/material.dart';

import '../theme.dart';

/// Privacy policy (plain text, also works offline).
/// NOTE: please have this reviewed by LRM India before publishing on Google Play, and publish the same
/// text on a web page (Google Play asks for a link) - for example lrmindia.org/Privacy-Policy.html.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _sections = <(String, String)>[
    ('Who we are',
        'ABBA Sunday School is a free app of Life Redemption Mission (LRM India), Jesus House, Nirai Valvu Nagar, 2nd Street, '
        'Opp to Car set, Virudhunagar 626001, India. Contact: lrm.india@yahoo.com.'),
    ('What the app stores on your phone',
        'The Bible lessons and songs you open are saved on your phone so you can read them without internet. '
        'Your settings (theme colour, font size) and, if you fill it in, your Profile (name, email, mobile number) are saved on your phone only. '
        'You can change or clear them at any time in the app, or by clearing the app\'s data in your phone settings.'),
    ('What we collect',
        'We do not collect anything automatically. There are no advertisements, no analytics or tracking tools, and no sign-in. '
        'We only receive information when you choose to send Feedback: your message, the type and rating, and the name, email and mobile number '
        'if you entered them. We use this only to improve the app and to reply to you if you gave an email address.'),
    ('Internet use',
        'The app connects to our online database (Supabase) to download or update lesson and song text. '
        'When you tap Download PDF, your phone opens a workbook file from lrmindia.org in your browser or PDF viewer. '
        'These requests may be visible to the hosting services as normal web traffic (for example your IP address).'),
    ('Sharing',
        'We do not sell or share your personal information. Feedback is visible only to the LRM India team. '
        'We may disclose information only if the law requires it.'),
    ('Children',
        'The lessons and songs are for children, but the app is meant to be used by teachers, parents and young people with an adult. '
        'We do not knowingly collect personal information from children. If a parent believes a child has sent personal details, '
        'please email us and we will delete it.'),
    ('Your choices',
        'You can use the app without a Profile. You can ask us to delete any feedback you sent by emailing lrm.india@yahoo.com.'),
    ('Changes',
        'If this policy changes, the new version will appear in the app. Last updated: November 2026.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        for (final (title, body) in _sections) ...[
          Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Brand.accent)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 15.5, height: 1.6)),
          const SizedBox(height: 18),
        ],
        Text('Copyright', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Brand.accent)),
        const SizedBox(height: 6),
        const Text('Copyright © Global Recordings Network. Used by permission.', style: TextStyle(fontSize: 15.5, height: 1.6)),
        const SizedBox(height: 10),
        const Text(
          "The Teacher's Guide in this app is copyrighted material of Global Recordings Network and is used here by permission. "
          'Please do not copy, reproduce or redistribute it without the permission of the copyright owner.',
          style: TextStyle(fontSize: 15.5, height: 1.6),
        ),
        const SizedBox(height: 14),
        Center(child: Image.asset('assets/grn.jpg', height: 110, fit: BoxFit.contain, semanticLabel: 'Global Recordings Network')),
        const SizedBox(height: 10),
      ]),
    );
  }
}
