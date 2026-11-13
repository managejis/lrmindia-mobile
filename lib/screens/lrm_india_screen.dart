import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../theme.dart';

/// About Life Redemption Mission (details from the website footer).
class LrmIndiaScreen extends StatelessWidget {
  const LrmIndiaScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open this link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LRM India')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(child: Image.asset('assets/logo.png', height: 70, errorBuilder: (_, __, ___) => Icon(Icons.church, size: 70, color: Brand.accent))),
        const SizedBox(height: 14),
        const Center(child: Text('Life Redemption Mission', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Brand.heading))),
        const SizedBox(height: 14),
        const Text(
          'Life Redemption Mission (LRM India) shares the good news of Jesus Christ with children, youth and families through '
          'Sunday school and VBS ministry, tracts and literature, training programmes and community service.\n\n'
          'ABBA Sunday School is a free app from LRM India. It brings the Bible lessons, workbooks, crafts, games and children\'s songs '
          'to teachers and parents in their own language, so they can use them anywhere, even without internet.',
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
        const SizedBox(height: 22),
        _row(Icons.place_outlined, 'Jesus House, Nirai Valvu Nagar, 2nd Street,\nOpp to Car set, Virudhunagar 626001', null),
        _row(Icons.phone_outlined, '(+91) 936-77-52-709', () => _open(context, 'tel:+919367752709')),
        _row(Icons.email_outlined, 'lrm.india@yahoo.com', () => _open(context, 'mailto:lrm.india@yahoo.com')),
        _row(Icons.language, 'lrmindia.org', () => _open(context, AppConfig.siteBase)),
        const SizedBox(height: 20),
        FilledButton.icon(onPressed: () => _open(context, AppConfig.siteBase), icon: const Icon(Icons.open_in_new), label: const Text('Visit our website')),
      ]),
    );
  }

  Widget _row(IconData icon, String text, VoidCallback? onTap) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Brand.accent),
        title: Text(text, style: TextStyle(fontSize: 15.5, height: 1.4, color: onTap == null ? Brand.text : Brand.accent)),
        onTap: onTap,
      );
}
