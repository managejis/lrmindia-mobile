/// Settings. Put your Supabase values here, OR pass them at build time:
///   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
/// Use the public *anon* key only (never the service_role key) - the app only reads.
class AppConfig {
  static const supabaseUrl =
      String.fromEnvironment('https://jiqoskmdwktspcotgdqh.supabase.co', defaultValue: 'https://jiqoskmdwktspcotgdqh.supabase.co');
  static const supabaseAnonKey =
      String.fromEnvironment('sb_publishable_6v9sg0v169F70pRsMPOwMA_qZjCQoQj', defaultValue: 'sb_publishable_6v9sg0v169F70pRsMPOwMA_qZjCQoQj');

  static bool get configured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static const siteBase = 'https://lrmindia.org';

  /// e.g. https://lrmindia.org/Resources/SundaySchool_Lessons/Hindi/Book-2-Mighty-Men-of-God/lesson-01/workbook-for-student.pdf
  static String workbookPdfUrl(String webFolder, String bookFolder, int lessonNo) =>
      '$siteBase/Resources/SundaySchool_Lessons/$webFolder/$bookFolder/'
      'lesson-${lessonNo.toString().padLeft(2, '0')}/workbook-for-student.pdf';
}
