-- ABBA Sunday School - Supabase (PostgreSQL) schema
-- Run once in:  Supabase dashboard > SQL Editor > New query > paste > Run.
--
-- Design: one row per language / book / lesson, and ONE ROW PER LESSON PART in lesson_contents
-- (teachers_guide, workbook_teacher, workbook_student, crafts, games). The text is stored as light
-- Markdown (headings, **bold**, *italic*, lists, tables) - no Word documents, only text.
-- Natural composite keys are used on purpose: re-running the upload is an idempotent upsert, and the
-- mobile app's SQLite database mirrors the same tables 1:1 for offline reading.

create extension if not exists pgcrypto;

-- ------------------------------------------------------------------ languages
create table if not exists public.languages (
  code        text primary key,                 -- 'hi', 'kn' (add 'ta','te','mr' ... later)
  name        text not null,                    -- 'Hindi'
  native_name text not null,                    -- 'हिन्दी'
  glyph       text not null,                    -- 'हि'  (letter shown on the language card)
  web_folder  text not null,                    -- 'Hindi'  = folder on lrmindia.org/Resources/SundaySchool_Lessons/<web_folder>/
  hero_lead   text,                             -- sentence under the landing-page heading
  sort_order  int  not null default 0,
  active      boolean not null default true,
  updated_at  timestamptz not null default now()
);

-- ------------------------------------------------------------------ books (9 per language)
create table if not exists public.books (
  lang_code    text not null references public.languages(code) on delete cascade,
  book_no      int  not null,
  title_en     text not null,                   -- 'Beginning with God'
  title_native text,
  folder       text not null,                   -- 'Book-1-Beginning-with-God' (used in the PDF link)
  color_a      text not null default '#dc3545', -- gradient colours of the book cover
  color_b      text not null default '#ff7a59',
  icon         text,                            -- bootstrap icon name from the website, e.g. 'bi-stars'
  lesson_count int  not null default 0,
  updated_at   timestamptz not null default now(),
  primary key (lang_code, book_no)
);

-- ------------------------------------------------------------------ lessons
create table if not exists public.lessons (
  lang_code    text not null,
  book_no      int  not null,
  lesson_no    int  not null,
  title_native text not null,
  title_en     text,
  updated_at   timestamptz not null default now(),
  primary key (lang_code, book_no, lesson_no),
  foreign key (lang_code, book_no) references public.books(lang_code, book_no) on delete cascade
);

-- ------------------------------------------------------------------ lesson parts (the 5 texts)
create table if not exists public.lesson_contents (
  lang_code   text not null,
  book_no     int  not null,
  lesson_no   int  not null,
  kind        text not null check (kind in
                ('teachers_guide','workbook_teacher','workbook_student','crafts','games')),
  body        text not null,                    -- Markdown text
  updated_at  timestamptz not null default now(),
  primary key (lang_code, book_no, lesson_no, kind),
  foreign key (lang_code, book_no, lesson_no) references public.lessons(lang_code, book_no, lesson_no) on delete cascade
);

-- ------------------------------------------------------------------ songs
create table if not exists public.songs (
  lang_code     text not null references public.languages(code) on delete cascade,
  song_no       int  not null,
  title_native  text not null,
  title_en      text,                           -- title in English letters
  lyrics_native text not null,
  lyrics_en     text,                           -- lyrics in English letters
  youtube_url   text,                           -- optional link to the song video
  updated_at    timestamptz not null default now(),
  primary key (lang_code, song_no)
);

-- for projects created before the YouTube link was added
alter table public.songs add column if not exists youtube_url text;

-- ------------------------------------------------------------------ indexes used by the app's incremental sync
create index if not exists books_upd   on public.books(lang_code, updated_at);
create index if not exists lessons_upd on public.lessons(lang_code, updated_at);
create index if not exists contents_upd on public.lesson_contents(lang_code, updated_at);
create index if not exists songs_upd   on public.songs(lang_code, updated_at);

-- ------------------------------------------------------------------ updated_at trigger
create or replace function public.touch_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

do $$
declare t text;
begin
  foreach t in array array['languages','books','lessons','lesson_contents','songs'] loop
    execute format('drop trigger if exists trg_touch on public.%I', t);
    execute format('create trigger trg_touch before insert or update on public.%I
                    for each row execute function public.touch_updated_at()', t);
  end loop;
end $$;

-- ------------------------------------------------------------------ security
-- The app only READS with the public anon key. Writing (the upload script) uses the service_role
-- key, which bypasses RLS. Never put the service_role key in the app.
do $$
declare t text;
begin
  foreach t in array array['languages','books','lessons','lesson_contents','songs'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "public read" on public.%I', t);
    execute format('create policy "public read" on public.%I for select to anon, authenticated using (true)', t);
  end loop;
end $$;

-- ------------------------------------------------------------------ feedback sent from the app's Feedback screen
-- The public key may only INSERT (nobody can read it back through the app). You read it in the Supabase table editor.
create table if not exists public.feedback (
  id          uuid primary key default gen_random_uuid(),
  category    text,
  rating      int check (rating between 1 and 5),
  message     text not null check (char_length(message) between 3 and 2000),
  name        text check (char_length(name) <= 80),
  email       text check (char_length(email) <= 120),
  mobile      text check (char_length(mobile) <= 20),
  app_version text,
  created_at  timestamptz not null default now()
);
alter table public.feedback enable row level security;
drop policy if exists "anyone can send feedback" on public.feedback;
create policy "anyone can send feedback" on public.feedback for insert to anon, authenticated with check (true);

-- ------------------------------------------------------------------ languages, in the order shown in the app
-- Odia and Urdu have no lessons yet (active = false -> "Coming soon"). The upload script keeps these rows up to date.
insert into public.languages (code, name, native_name, glyph, web_folder, sort_order, active) values
  ('en','English',  'English',  'E',  'English',  1,  true),
  ('ta','Tamil',    'தமிழ்',     'த',  'Tamil',    2,  true),
  ('te','Telugu',   'తెలుగు',    'తె', 'Telugu',   3,  true),
  ('kn','Kannada',  'ಕನ್ನಡ',     'ಕ',  'Kannada',  4,  true),
  ('bn','Bengali',  'বাংলা',     'বা', 'Bengali',  5,  true),
  ('gu','Gujarati', 'ગુજરાતી',   'ગુ', 'Gujarati', 6,  true),
  ('ml','Malayalam','മലയാളം',   'മ',  'Malayalam',7,  true),
  ('mr','Marathi',  'मराठी',     'म',  'Marathi',  8,  true),
  ('hi','Hindi',    'हिन्दी',    'हि', 'Hindi',    9,  true),
  ('or','Odia',     'ଓଡ଼ିଆ',     'ଓ',  'Odia',     10, true),
  ('ur','Urdu',     'اردو',      'ا',  'Urdu',     11, true),
  ('zh','Mandarin Chinese', '中文', '中', 'Mandarin-Chinese', 12, true),
  ('es','Spanish', 'Español', 'Es', 'Spanish', 13, true),
  ('ar','Standard Arabic', 'العربية', 'ع', 'Standard-Arabic', 14, true),
  ('fr','French', 'Français', 'Fr', 'French', 15, true),
  ('pt','Portuguese', 'Português', 'Pt', 'Portuguese', 16, true),
  ('id','Indonesian', 'Bahasa Indonesia', 'Id', 'Indonesian', 17, true),
  ('ru','Russian', 'Русский', 'Р', 'Russian', 18, true),
  ('de','German', 'Deutsch', 'De', 'German', 19, true),
  ('ja','Japanese', '日本語', '日', 'Japanese', 20, true)
on conflict (code) do update set sort_order = excluded.sort_order, native_name = excluded.native_name, glyph = excluded.glyph;
