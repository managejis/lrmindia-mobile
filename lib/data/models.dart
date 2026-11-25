import 'dart:ui' show TextDirection;

class Language {
  final String code, name, nativeName, glyph, webFolder;
  final String? heroLead;
  final int sortOrder;
  final bool active;   // false = no lessons yet ("coming soon")
  /// Urdu is written right to left.
  bool get isRtl => code == 'ur' || code == 'ar';
  TextDirection get textDirection => isRtl ? TextDirection.rtl : TextDirection.ltr;
  Language({required this.code, required this.name, required this.nativeName, required this.glyph,
      required this.webFolder, this.heroLead, this.sortOrder = 0, this.active = true});

  factory Language.fromMap(Map<String, dynamic> m) => Language(
        code: m['code'] as String,
        name: m['name'] as String,
        nativeName: m['native_name'] as String,
        glyph: m['glyph'] as String,
        webFolder: m['web_folder'] as String,
        heroLead: m['hero_lead'] as String?,
        sortOrder: (m['sort_order'] as num?)?.toInt() ?? 0,
        active: m['active'] == null ? true : (m['active'] == true || m['active'] == 1),
      );
}

class Book {
  final String langCode, titleEn, folder, colorA, colorB;
  final String? titleNative;
  final int bookNo, lessonCount;
  final String? icon;
  Book({required this.langCode, required this.bookNo, required this.titleEn, this.titleNative, required this.folder,
      required this.colorA, required this.colorB, this.icon, required this.lessonCount});

  /// Regional-language title when we have it, otherwise English.
  String get mainTitle => (titleNative == null || titleNative!.trim().isEmpty) ? titleEn : titleNative!;
  bool get hasNative => titleNative != null && titleNative!.trim().isNotEmpty;

  factory Book.fromMap(Map<String, dynamic> m) => Book(
        langCode: m['lang_code'] as String,
        bookNo: (m['book_no'] as num).toInt(),
        titleEn: m['title_en'] as String,
        titleNative: m['title_native'] as String?,
        folder: m['folder'] as String,
        colorA: (m['color_a'] as String?) ?? '#dc3545',
        colorB: (m['color_b'] as String?) ?? '#ff7a59',
        icon: m['icon'] as String?,
        lessonCount: (m['lesson_count'] as num?)?.toInt() ?? 0,
      );
}

class Lesson {
  final String langCode, titleNative;
  final String? titleEn;
  final int bookNo, lessonNo;
  Lesson({required this.langCode, required this.bookNo, required this.lessonNo, required this.titleNative, this.titleEn});

  factory Lesson.fromMap(Map<String, dynamic> m) => Lesson(
        langCode: m['lang_code'] as String,
        bookNo: (m['book_no'] as num).toInt(),
        lessonNo: (m['lesson_no'] as num).toInt(),
        titleNative: m['title_native'] as String,
        titleEn: m['title_en'] as String?,
      );
}

/// The five texts of a lesson, in tab order.
enum LessonKind {
  teachersGuide('teachers_guide', "Teacher's Guide"),
  workbookTeacher('workbook_teacher', 'Teacher Workbook (Answers)'),
  workbookStudent('workbook_student', 'Student Workbook'),
  crafts('crafts', 'Crafts'),
  games('games', 'Games');

  final String key, label;
  const LessonKind(this.key, this.label);
}

class Song {
  final String langCode, titleNative, lyricsNative;
  final String? titleEn, lyricsEn, youtubeUrl;
  final int songNo;
  Song({required this.langCode, required this.songNo, required this.titleNative, this.titleEn,
      required this.lyricsNative, this.lyricsEn, this.youtubeUrl});

  factory Song.fromMap(Map<String, dynamic> m) => Song(
        langCode: m['lang_code'] as String,
        songNo: (m['song_no'] as num).toInt(),
        titleNative: m['title_native'] as String,
        titleEn: m['title_en'] as String?,
        lyricsNative: (m['lyrics_native'] as String?) ?? '',
        lyricsEn: m['lyrics_en'] as String?,
        youtubeUrl: m['youtube_url'] as String?,
      );
}
