import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../settings.dart';
import '../theme.dart';

/// Sends feedback to the `feedback` table in Supabase (insert-only for the public key).
/// If that is not possible (offline / not configured) it offers to send the same text by email instead.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const _types = ['Suggestion', 'Problem', 'Compliment', 'Other'];
  final _form = GlobalKey<FormState>();
  final _msg = TextEditingController();
  final _name = TextEditingController(text: AppSettings.instance.name);
  final _email = TextEditingController(text: AppSettings.instance.email);
  String _type = _types.first;
  int _rating = 0;
  bool _sending = false;

  @override
  void dispose() {
    _msg.dispose();
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      if (!AppConfig.configured) throw StateError('not configured');
      await Supabase.instance.client.from('feedback').insert({
        'category': _type,
        'rating': _rating == 0 ? null : _rating,
        'message': _msg.text.trim(),
        'name': _name.text.trim().isEmpty ? null : _name.text.trim(),
        'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
        'mobile': AppSettings.instance.mobile.isEmpty ? null : AppSettings.instance.mobile,
        'app_version': '1.0.0',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you! Your feedback was sent.')));
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      final viaMail = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Could not send'),
          content: const Text('The feedback could not be sent from the app right now (no internet?). Send it by email instead?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Email')),
          ],
        ),
      );
      if (viaMail == true) {
        final body = '${_msg.text.trim()}\n\n— ${_name.text.trim()} ${_email.text.trim()} ${AppSettings.instance.mobile}'
            '\nType: $_type${_rating > 0 ? ', rating: $_rating/5' : ''}';
        await launchUrl(Uri(scheme: 'mailto', path: 'lrm.india@yahoo.com', queryParameters: {'subject': 'ABBA Sunday School feedback', 'body': body}));
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('We would love to hear from you.', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Brand.heading)),
        const SizedBox(height: 4),
        const Text('Tell us what is helpful, what is wrong, or what you would like to see.'),
        const SizedBox(height: 18),
        Form(
          key: _form,
          child: Column(children: [
            Wrap(spacing: 8, children: [
              for (final t in _types)
                ChoiceChip(label: Text(t), selected: _type == t, selectedColor: Brand.accent.withOpacity(.18), onSelected: (_) => setState(() => _type = t)),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              const Text('Rating:  '),
              for (var i = 1; i <= 5; i++)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _rating = _rating == i ? 0 : i),
                  icon: Icon(i <= _rating ? Icons.star : Icons.star_border, color: Brand.accent),
                ),
            ]),
            const SizedBox(height: 6),
            TextFormField(
              controller: _msg,
              minLines: 5,
              maxLines: 9,
              maxLength: 2000,
              decoration: InputDecoration(labelText: 'Your feedback', alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
              validator: (v) => (v ?? '').trim().length < 3 ? 'Please write a few words' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name (optional)', prefixIcon: Icon(Icons.badge_outlined))),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email (optional, if you want a reply)', prefixIcon: Icon(Icons.email_outlined)),
              validator: (v) {
                final t = (v ?? '').trim();
                return t.isEmpty || RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t) ? null : 'Enter a valid email address';
              },
            ),
          ]),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _sending ? null : _send,
          icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send),
          label: Text(_sending ? 'Sending…' : 'Send feedback'),
        ),
      ]),
    );
  }
}
