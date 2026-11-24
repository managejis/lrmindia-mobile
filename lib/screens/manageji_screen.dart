import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';

/// ManageJi: the company that developed this application (details from https://manageji.com/).
class ManageJiScreen extends StatelessWidget {
  const ManageJiScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open this link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const services = [
      'Website design and redesign',
      'Custom web development',
      'E-commerce development',
      'Website maintenance and support',
      'Domain and hosting services',
      'SEO and digital marketing',
      'Software services and web app development',
      'Technology training',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('ManageJi')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(child: Image.asset('assets/manageji.png', height: 64, errorBuilder: (_, __, ___) => Icon(Icons.code_rounded, size: 64, color: Brand.accent))),
        const SizedBox(height: 14),
        const Center(child: Text('ManageJi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Brand.heading))),
        const SizedBox(height: 4),
        Center(child: Text('Developer of ABBA Sunday School', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Brand.accent))),
        const SizedBox(height: 16),
        const Text(
          'ManageJi is a professional web designing company based in Bangalore. Its aim is to provide high quality, responsive and '
          'cost-effective web designing services.\n\n'
          'ManageJi designed and developed this ABBA Sunday School application for Life Redemption Mission (LRM India).',
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
        const SizedBox(height: 18),
        const Text('What ManageJi offers', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Brand.heading)),
        const SizedBox(height: 6),
        for (final s in services)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.check_circle_outline, size: 19, color: Brand.accent),
              const SizedBox(width: 10),
              Expanded(child: Text(s, style: const TextStyle(fontSize: 15.5, height: 1.4))),
            ]),
          ),
        const SizedBox(height: 18),
        const Text('Contact', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Brand.heading)),
        const SizedBox(height: 4),
        _row(Icons.place_outlined, '57, Kaveri Nagar, Vodrapalya,\nBengaluru, India - 560043', null),
        _row(Icons.phone_outlined, '+91 866 744 64 68', () => _open(context, 'tel:+918667446468')),
        _row(Icons.email_outlined, 'info@manageji.com', () => _open(context, 'mailto:info@manageji.com')),
        _row(Icons.language, 'manageji.com', () => _open(context, 'https://manageji.com/')),
        _row(Icons.schedule, 'Monday - Friday, 9:00 AM - 5:00 PM', null),
        const SizedBox(height: 20),
        FilledButton.icon(onPressed: () => _open(context, 'https://manageji.com/'), icon: const Icon(Icons.open_in_new), label: const Text('Visit manageji.com')),
        const SizedBox(height: 16),
        Center(child: Text('© ManageJi. All rights reserved.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12))),
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
