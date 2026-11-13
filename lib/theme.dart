import 'package:flutter/material.dart';

/// Same look as the LRM India website (main.css): red accent, slate body text, white surfaces.
class Brand {
  static const defaultAccent = Color(0xFFDC3545);
  /// The theme colour chosen in Settings (changes at run time).
  static Color accent = defaultAccent;
  static const text = Color(0xFF4E5D6B);
  static const heading = Color(0xFF2C2C2C);
  static const bg = Color(0xFFF7F9F9);

  /// A darker shade of the theme colour (for headings and gradients).
  static Color get accentDark {
    final h = HSLColor.fromColor(accent);
    return h.withLightness((h.lightness * 0.72).clamp(0.0, 1.0)).toColor();
  }

  /// Very light tint of the theme colour for page backgrounds.
  static Color get tint => Color.alphaBlend(accent.withValues(alpha: 0.05), Colors.white);

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(seedColor: accent, primary: accent, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: accent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      textTheme: ThemeData.light().textTheme.apply(bodyColor: text, displayColor: heading),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide(color: accent)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    );
  }

  static Color hex(String? s, [Color? fallbackColor]) {
    final fallback = fallbackColor ?? accent;
    if (s == null) return fallback;
    final h = s.replaceAll('#', '').trim();
    if (h.length != 6) return fallback;
    final v = int.tryParse(h, radix: 16);
    return v == null ? fallback : Color(0xFF000000 | v);
  }
}
