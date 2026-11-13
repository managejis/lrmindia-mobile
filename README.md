# ABBA Sunday School (Flutter, Android)

Bible lessons and children's songs in English, Tamil, Telugu, Kannada, Bengali, Gujarati, Malayalam, Marathi and Hindi (Odia and Urdu are listed as *Coming soon*) for Sunday-school teachers.
Text only - no Word files. Content lives in **Supabase (PostgreSQL)**, is copied to **SQLite** on the phone
for offline reading, and the student workbook PDF is downloaded from **lrmindia.org** on request.

## How the app works
1. Opens on the **language list** (same cards as the website).
2. Tap a language -> its **landing page** (hero, stats, search, 9 book cards with all lessons) - same look and
   wording as `Christian-Sunday-School-Kids-Children-Lessons-<Language>.html`.
3. First time only: the language's text is downloaded from Supabase into SQLite (progress bar). After that
   everything works offline; when internet is available the app quietly fetches only what changed.
4. Tap a lesson -> tabs: **Teacher's Guide - Teacher Workbook (Answers) - Student Workbook - Crafts - Games**,
   previous/next lesson. The Student Workbook tab (and the PDF icon on top) opens
   `https://lrmindia.org/Resources/SundaySchool_Lessons/<Language>/<Book folder>/lesson-NN/workbook-for-student.pdf`.
5. Songs (music-note icon): searchable list, native script / English toggle, Share, Copy.

### Burger menu (top-left)
| Item | What it does |
|---|---|
| Lessons | Back to the Welcome screen (list of languages). |
| Songs | Choose a language, then its songs. |
| Profile | Name, email, mobile number - saved on the phone only. |
| Settings | Theme colour (8 colours), font size slider with live preview, and the **Sunday class alert** (weekly reminder; choose day and time; it names the next lesson you have not completed). |
| LRM India | About the mission, address, call / email / website buttons. |
| Feedback | Sends to the `feedback` table in Supabase (email fallback if offline). Read it in the Supabase table editor. |
| Privacy Policy | Draft text - please have LRM India review it, and publish the same text on the website (Google Play asks for a link). |

## Folders
| Path | What |
|---|---|
| `supabase/schema.sql` | Database design: `languages`, `books`, `lessons`, `lesson_contents` (one row per lesson part: teachers_guide, workbook_teacher, workbook_student, crafts, games), `songs`. Public read-only (RLS). |
| `tools/extract_and_upload.py` | Reads your website + docx files, extracts text, uploads to Supabase. |
| `lib/` | Flutter app (`data/local_db.dart` = SQLite mirror, `data/repository.dart` = Supabase -> SQLite sync). |
| `setup.ps1` | Creates the Android project and patches the manifest. |

## Set-up, step by step
1. **Supabase**: create a project at https://supabase.com. Open *SQL Editor*, paste `supabase/schema.sql`, Run.
2. **Load the text** (from this folder, PowerShell):
   ```powershell
   python tools\extract_and_upload.py                    # reads D:\AI_Claude\SundaySchool_<Language>\ (Word files) -> data\english.json, data\tamil.json ...
   python tools\extract_and_upload.py --lang=tamil       # only one language
   $env:SUPABASE_URL = "https://xxxx.supabase.co"
   $env:SUPABASE_SERVICE_KEY = "<service_role key: Project Settings > API>"
   python tools\extract_and_upload.py --upload           # safe to run again after you edit lessons
   ```
   Keep the service_role key private; it is only for this script, never for the app.
3. **App keys**: put *Project URL* and the public *anon* key in `lib/config.dart` (or pass `--dart-define`).
4. **Android project**: `.\setup.ps1` (needs Flutter + Android Studio / SDK). If you already ran it before the reminder feature was added, run `.\patch_android.ps1` once, then `flutter pub get`.
5. **Run / build**:
   ```powershell
   flutter run                       # on a phone or emulator
   flutter build apk --release       # build\app\outputs\flutter-apk\app-release.apk
   ```

## Adding a language later (Odia, Urdu, ...)
Put its Word files in `D:\AI_Claude\SundaySchool_Odia\Book-N-...\<n. Lesson>\` (same layout as the others), run the extractor with `--upload`,
and the language switches from *Coming soon* to active automatically (it is already in `LANGS` in `tools/extract_and_upload.py`,
in `schema.sql` and in the built-in list in `lib/data/local_db.dart`). Language order is set by `sort` / `sort_order` in those places.

## Updating lessons
Edit the website/docx as usual, run `python tools\extract_and_upload.py --upload` again. Phones pick up the
changes next time they open that language with internet. (Rows removed on the website are not removed from
phones; delete them in Supabase and clear the app's data if ever needed.)

## Completed lessons, book titles, YouTube
- Every lesson has a **Mark done** button; completed lessons get a green tick on the landing page and each book shows `x / N completed`. This is kept on the phone only. "Start/Continue Lesson" jumps to the first lesson not yet completed.
- Landing-page book titles are shown in the regional language (big) with English underneath (small). Bengali, Gujarati, Malayalam and Marathi book names are read from the Teacher's Guides; Tamil, Telugu, Hindi and Kannada have none there, so the translations in `BOOK_TITLES_FALLBACK` at the top of `tools/extract_and_upload.py` are used - please have them checked. Run the upload again to publish them.
- Songs: the **Watch on YouTube** button opens the song's video if a link is stored; otherwise it becomes **Find on YouTube** and searches for the song. To add links: run the extractor, open `data\youtube_links_template.csv`, fill the `url` column, save it as `tools\youtube_links.csv`, then run `python tools\extract_and_upload.py --upload`. Links already on the website's song pages (the `Watch on YouTube` button) are picked up automatically.
- After updating the app on a phone that already has data, the app re-downloads the text once (new columns).
