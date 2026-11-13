import 'package:flutter/material.dart';

import '../settings.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(text: AppSettings.instance.name);
  final _email = TextEditingController(text: AppSettings.instance.email);
  final _mobile = TextEditingController(text: AppSettings.instance.mobile);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    await AppSettings.instance.saveProfile(name: _name.text, email: _email.text, mobile: _mobile.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(
          child: CircleAvatar(
            radius: 42,
            backgroundColor: Brand.accent.withOpacity(.12),
            child: Icon(Icons.person, size: 48, color: Brand.accent),
          ),
        ),
        const SizedBox(height: 22),
        Form(
          key: _form,
          child: Column(children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.badge_outlined)),
              validator: (v) => (v ?? '').trim().length > 80 ? 'Name is too long' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return null;
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t) ? null : 'Enter a valid email address';
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _mobile,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile number', prefixIcon: Icon(Icons.phone_android)),
              validator: (v) {
                final t = (v ?? '').replaceAll(RegExp(r'[\s\-()]'), '');
                if (t.isEmpty) return null;
                return RegExp(r'^\+?\d{10,14}$').hasMatch(t) ? null : 'Enter a valid mobile number';
              },
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Text('Your details stay on this phone. They are only sent if you choose to send feedback.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(height: 22),
        FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: const Text('Save')),
      ]),
    );
  }
}
