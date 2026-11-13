import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'notifications.dart';
import 'screens/languages_screen.dart';
import 'settings.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.load();
  if (AppConfig.configured) {
    // Does not need internet to initialise; the app keeps working offline from SQLite.
    await Supabase.initialize(url: AppConfig.supabaseUrl, anonKey: AppConfig.supabaseAnonKey);
  }
  runApp(const AbbaApp());
  Notifier.refresh();   // re-plan the Sunday preparation alert (also names the next lesson)
}

class AbbaApp extends StatelessWidget {
  const AbbaApp({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: AppSettings.instance,
        builder: (context, _) => MaterialApp(
          title: 'ABBA Sunday School',
          debugShowCheckedModeBanner: false,
          theme: Brand.theme(),
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(textScaler: TextScaler.linear(mq.textScaler.scale(1) * AppSettings.instance.fontScale)),
              // keep every screen clear of the Android back / home buttons at the bottom
              child: SafeArea(top: false, left: false, right: false, child: child ?? const SizedBox.shrink()),
            );
          },
          home: const LanguagesScreen(),
        ),
      );
}
