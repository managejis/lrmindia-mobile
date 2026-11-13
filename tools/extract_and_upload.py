#!/usr/bin/env python3
"""ABBA Sunday School - extract the TEXT of the lessons (and songs) and load it into Supabase.

Lessons come from the Word files, one folder per language:
    D:\\AI_Claude\\SundaySchool_<Language>\\Book-N-...\\<n>. <Lesson>\\1. Teacher's-Guide..., 2. Workbook-For-Student, 3. Crafts,
                                                                   4. Games, 5. Workbook-For-Teacher - With-Answer
Only the text is kept (as light Markdown) - no Word/PDF files are copied.
Songs come from the website folder  <site>\\Resources\\Children_Songs\\<Language>  (English, Hindi, Kannada, Tamil).

Step 1 - extract to JSON (no internet needed):
    python extract_and_upload.py                       -> data\\english.json, data\\tamil.json, ...
Step 2 - upload to Supabase (after running supabase\\schema.sql):
    set SUPABASE_URL=https://xxxx.supabase.co
    set SUPABASE_SERVICE_KEY=<service_role key from Project Settings > API>
    python extract_and_upload.py --upload              (safe to repeat: rows are upserted)

Options:  --lang=english,tamil   (default: every language that has a folder)   --docs=D:\\AI_Claude
          --site=D:\\Paul\\Ministry\\LRM\\Website\\webProject\\lrmindia   --out=data
Python 3.8+, standard library only.
"""
import os, re, sys, csv, json, html, zipfile, urllib.request, urllib.error
import xml.etree.ElementTree as ET

def opt(name, default):
    for a in sys.argv[1:]:
        if a.startswith('--' + name + '='): return a.split('=', 1)[1]
    return default

DOCS = opt('docs', r'D:\AI_Claude')
SITE = opt('site', r'D:\Paul\Ministry\LRM\Website\webProject\lrmindia')
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = opt('out', os.path.join(HERE, '..', 'data'))
ONLY = [x.strip().lower() for x in opt('lang', '').split(',') if x.strip()]
UPLOAD = '--upload' in sys.argv

# Order shown in the app (sort) - Hindi was added after Marathi. Odia and Urdu have no lessons yet ("coming soon").
LANGS = [
    dict(folder='English',   code='en', native='English',   glyph='E',  sort=1,  songs='English'),
    dict(folder='Tamil',     code='ta', native='தமிழ்',      glyph='த',  sort=2,  songs='Tamil'),
    dict(folder='Telugu',    code='te', native='తెలుగు',     glyph='తె', sort=3,  songs=None),
    dict(folder='Kannada',   code='kn', native='ಕನ್ನಡ',      glyph='ಕ',  sort=4,  songs='Kannada'),
    dict(folder='Bengali',   code='bn', native='বাংলা',      glyph='বা', sort=5,  songs=None),
    dict(folder='Gujarati',  code='gu', native='ગુજરાતી',    glyph='ગુ', sort=6,  songs=None),
    dict(folder='Malayalam', code='ml', native='മലയാളം',    glyph='മ',  sort=7,  songs=None),
    dict(folder='Marathi',   code='mr', native='मराठी',      glyph='म',  sort=8,  songs=None),
    dict(folder='Hindi',     code='hi', native='हिन्दी',     glyph='हि', sort=9,  songs='Hindi'),
    dict(folder='Odia',      code='or', native='ଓଡ଼ିଆ',      glyph='ଓ',  sort=10, songs=None),
    dict(folder='Urdu',      code='ur', native='اردو',       glyph='ا',  sort=11, songs=None),
]

# The nine books (same for every language): English title, website folder (for the PDF link), cover colours, icon.
BOOKS = {
    1: ('Beginning with God',        'Book-1-Beginning-with-God',        '#dc3545', '#ff7a59', 'bi-stars'),
    2: ('Mighty Men of God',         'Book-2-Mighty-Men-of-God',         '#0d6efd', '#4cc9f0', 'bi-shield-shaded'),
    3: ('Victory through God',       'Book-3-Victory-through-God',       '#198754', '#7bd88f', 'bi-trophy'),
    4: ('Servants of God',           'Book-4-Servants-of-God',           '#fd7e14', '#ffc107', 'bi-heart'),
    5: ('On Trial for God',          'Book-5-On-Trial-for-God',          '#6f42c1', '#d63384', 'bi-lightning-charge'),
    6: ('Jesus, Teacher and Healer', 'Book-6-Jesus-Teacher-and-Healer',  '#0aa2c0', '#20c997', 'bi-book'),
    7: ('Jesus, Lord and Saviour',   'Book-7-Jesus-Lord-and-Saviour',    '#b02a37', '#fd7e14', 'bi-patch-check-fill'),
    8: ('Acts of the Holy Spirit',   'Book-8-Acts-of-the-Holy-Spirit',   '#5b2a86', '#0d6efd', 'bi-fire'),
    9: ('Good News',                 'Book-9-Good-News',                 '#146c43', '#0aa2c0', 'bi-globe-americas'),
}

# Regional book names are read from each language's Teacher's Guide (line "... – Book 1: <name>") when it has one.
# Where it does not (Tamil, Telugu, Hindi, Kannada), these names - translated for the app - are used instead.
# Please have them checked by a reader of that language and correct them here if needed.
BOOK_TITLES_FALLBACK = {
    'ta': {1: 'தேவனுடன் தொடக்கம்', 2: 'தேவனுடைய வல்லமையுள்ள மனிதர்கள்', 3: 'தேவனால் வெற்றி', 4: 'தேவனுடைய ஊழியக்காரர்கள்',
           5: 'தேவனுக்காக விசாரணையில்', 6: 'இயேசு, போதகரும் சுகம் அளிப்பவரும்', 7: 'இயேசு, ஆண்டவரும் இரட்சகரும்',
           8: 'பரிசுத்த ஆவியின் செயல்கள்', 9: 'நற்செய்தி'},
    'te': {1: 'దేవునితో ఆరంభం', 2: 'దేవుని బలవంతులైన మనుషులు', 3: 'దేవుని ద్వారా విజయం', 4: 'దేవుని సేవకులు',
           5: 'దేవుని కోసం విచారణలో', 6: 'యేసు, బోధకుడు మరియు స్వస్థపరచువాడు', 7: 'యేసు, ప్రభువు మరియు రక్షకుడు',
           8: 'పరిశుద్ధాత్మ కార్యాలు', 9: 'సువార్త'},
    'hi': {1: 'परमेश्वर के साथ आरंभ', 2: 'परमेश्वर के शक्तिशाली पुरुष', 3: 'परमेश्वर के द्वारा विजय', 4: 'परमेश्वर के सेवक',
           5: 'परमेश्वर के लिए परीक्षा में', 6: 'यीशु, शिक्षक और चंगाई देनेवाला', 7: 'यीशु, प्रभु और उद्धारकर्ता',
           8: 'पवित्र आत्मा के कार्य', 9: 'शुभ समाचार'},
    'kn': {1: 'ದೇವರೊಂದಿಗೆ ಆರಂಭ', 2: 'ದೇವರ ಪರಾಕ್ರಮಿ ಪುರುಷರು', 3: 'ದೇವರ ಮೂಲಕ ಜಯ', 4: 'ದೇವರ ಸೇವಕರು',
           5: 'ದೇವರಿಗಾಗಿ ವಿಚಾರಣೆಯಲ್ಲಿ', 6: 'ಯೇಸು, ಬೋಧಕ ಮತ್ತು ಗುಣಪಡಿಸುವವನು', 7: 'ಯೇಸು, ಪ್ರಭು ಮತ್ತು ರಕ್ಷಕ',
           8: 'ಪವಿತ್ರಾತ್ಮನ ಕಾರ್ಯಗಳು', 9: 'ಶುಭವಾರ್ತೆ'},
}

KIND_BY_PREFIX = {1: 'teachers_guide', 2: 'workbook_student', 3: 'crafts', 4: 'games', 5: 'workbook_teacher'}
W = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'

# ------------------------------------------------------------------ text helpers
def esc(t):
    t = t.replace('\\', '\\\\')
    for ch in '*_`[]|<>': t = t.replace(ch, '\\' + ch)
    return t

def norm(t):
    return re.sub(r'[ \t\r\n\xa0\u200b]+', ' ', t).strip()

def tidy_inline(s):
    s = re.sub(r'\*\*(\s*)\*\*', r'\1', s)                       # "**a** **b**" -> "**a b**"
    s = re.sub(r'\*\*(\s*)(.*?)(\s*)\*\*', lambda m: m.group(1) + ('**' + m.group(2) + '**' if m.group(2) else '') + m.group(3), s)
    return re.sub(r'[ \t]{2,}', ' ', s).strip()

def plain(p): return norm(''.join(t.text or '' for t in p.iter(W + 't')))

# ------------------------------------------------------------------ docx
def docx_body(path):
    with zipfile.ZipFile(path) as z: return ET.fromstring(z.read('word/document.xml')).find(W + 'body')

def docx_paras(path):
    return [t for t in (plain(p) for p in docx_body(path).iter(W + 'p')) if t]

def docx_markdown(path, drop_head=False):
    body = docx_body(path)
    def runs(p):
        out = []
        for r in p.iter(W + 'r'):
            rpr = r.find(W + 'rPr')
            b = i = False
            if rpr is not None:
                be, ie = rpr.find(W + 'b'), rpr.find(W + 'i')
                b = be is not None and be.get(W + 'val') not in ('0', 'false')
                i = ie is not None and ie.get(W + 'val') not in ('0', 'false')
            s = ''
            for c in r:
                if c.tag == W + 't': s += esc(c.text or '')
                elif c.tag in (W + 'tab', W + 'br', W + 'cr'): s += ' '
            if not s.strip(): out.append(s); continue
            if i: s = '*' + s.strip() + '* '
            if b: s = '**' + s.strip() + '** '
            out.append(s)
        return tidy_inline(norm(''.join(out)))

    kids = list(body)
    if drop_head:
        # the lesson number, the lesson title and the "Teacher's Guide · Book n: ..." line are already shown by the app
        seen, drop = 0, set()
        for idx, e in enumerate(kids):
            if e.tag != W + 'p' or not plain(e): continue
            seen += 1
            t = plain(e)
            if seen == 1 and re.match(r'^\D{1,14}\s*\d+\s*$', t): drop.add(idx)
            elif seen == 2 and drop: drop.add(idx)
            elif seen == 3 and drop and '·' in t: drop.add(idx)
            if seen >= 3: break
        kids = [e for idx, e in enumerate(kids) if idx not in drop]

    blocks = []
    for e in kids:
        if e.tag == W + 'p':
            t = runs(e)
            if not t: continue
            ppr = e.find(W + 'pPr'); st = ''; num = False
            if ppr is not None:
                s_ = ppr.find(W + 'pStyle'); st = (s_.get(W + 'val') if s_ is not None else '') or ''
                num = ppr.find(W + 'numPr') is not None
            m = re.match(r'heading\s*(\d)', st.lower().replace(' ', ''))
            if m: blocks.append('#' * min(int(m.group(1)) + 1, 4) + ' ' + t.replace('**', ''))
            elif num: blocks.append('- ' + t)
            else: blocks.append(t)
        elif e.tag == W + 'tbl':
            rows = []
            for tr in e.findall(W + 'tr'):
                cells = []
                for tc in tr.findall(W + 'tc'):
                    cells.append(' '.join(x for x in (runs(p) for p in tc.findall(W + 'p')) if x) or ' ')
                rows.append(cells)
            if rows:
                n = max(len(r) for r in rows)
                ln = lambda r: '| ' + ' | '.join((r[i] if i < len(r) else ' ') for i in range(n)) + ' |'
                blocks.append('\n'.join([ln(rows[0]), '|' + '---|' * n] + [ln(r) for r in rows[1:]]))
    return '\n\n'.join(blocks).strip()

# ------------------------------------------------------------------ discovery
def num_prefix(name):
    m = re.match(r'(\d+)\.', name)
    return int(m.group(1)) if m else None

def books_of(lang_dir):
    res = {}
    if os.path.isdir(lang_dir):
        for d in os.listdir(lang_dir):
            m = re.match(r'Book-(\d+)-', d)
            if m and os.path.isdir(os.path.join(lang_dir, d)): res[int(m.group(1))] = os.path.join(lang_dir, d)
    return res

def lessons_of(book_dir):
    res = {}
    for d in os.listdir(book_dir):
        n = num_prefix(d); full = os.path.join(book_dir, d)
        if n is None or not os.path.isdir(full): continue
        files = {}
        for f in os.listdir(full):
            if not f.lower().endswith('.docx') or f.startswith('~$'): continue
            k = num_prefix(f)
            # the Teacher's Guide is numbered with the lesson number in many folders ("14. Teacher's-Guide-...")
            if re.match(r"\d+\.\s*teachers?['’]?s?-?\s*guide", f, re.I): kind = 'teachers_guide'
            else: kind = KIND_BY_PREFIX.get(k)
            if kind and kind not in files: files[kind] = os.path.join(full, f)
        res[n] = (re.sub(r'^\d+\.\s*', '', d).strip(), files)
    return res

def lesson_title(files, fallback):
    """The lesson title in the language of the document."""
    if 'teachers_guide' in files:
        ps = docx_paras(files['teachers_guide'])
        if len(ps) > 1 and re.match(r'^\D{1,14}\s*\d+\s*$', ps[0]): return ps[1].strip()
    for key in ('workbook_student', 'workbook_teacher'):
        if key in files:
            ps = docx_paras(files[key])
            if ps:
                m = re.match(r'^.{1,15}?-?\s*\d+\s*[:：]\s*(.+)$', ps[0])
                if m: return m.group(1).strip()
    return fallback

def native_book_title(files):
    """From the line  '<Teacher's Guide> · <series> – Book 1: <book name>'  of lesson 1 (not every language has it)."""
    if 'teachers_guide' not in files: return None
    ps = docx_paras(files['teachers_guide'])
    if len(ps) > 2 and '·' in ps[2]:
        m = re.search(r'\d+\s*[:：]\s*(.+)$', ps[2])
        if m: return m.group(1).strip()
    return None

# ------------------------------------------------------------------ songs (website pages)
def parse_songs(web_folder):
    if not web_folder: return []
    d = os.path.join(SITE, 'Resources', 'Children_Songs', web_folder)
    if not os.path.isdir(d): return []
    songs = []
    for f in sorted(x for x in os.listdir(d) if re.match(r'song-\d+\.html$', x)):
        with open(os.path.join(d, f), encoding='utf-8') as fh: t = fh.read()
        n = int(re.search(r'song-(\d+)', f).group(1))
        h = re.search(r'<h1 class="song-title"([^>]*)>(.*?)</h1>', t, re.S)
        if not h: continue
        en = re.search(r'data-title-en="([^"]*)"', h.group(1))
        title = html.unescape(re.sub(r'<[^>]+>', '', h.group(2))).strip()
        ly = dict(re.findall(r'<div class="song-lyrics[^"]*" data-lyrics-(\w+)[^>]*>(.*?)</div>', t, re.S))
        nat = [k for k in ly if k != 'en']
        lyr_native = html.unescape(ly[nat[0]]).strip() if nat else html.unescape(ly.get('en', '')).strip()
        lyr_en = html.unescape(ly.get('en', '')).strip() if nat else None
        yt = re.search(r'class="btn-video"[^>]*href="([^"]+)"|href="(https://www\.youtube\.com/watch[^"]+)"[^>]*class="btn-video"', t)
        songs.append(dict(no=n, title_native=title, title_en=html.unescape(en.group(1)) if en else None,
                          lyrics_native=lyr_native, lyrics_en=lyr_en or None,
                          youtube_url=html.unescape(yt.group(1) or yt.group(2)) if yt else None))
    return songs

YT_CSV = os.path.join(HERE, 'youtube_links.csv')
def load_youtube_csv():
    """tools\\youtube_links.csv with columns lang,song_no,url (lang = en, ta, kn, hi ...). Optional."""
    res = {}
    if os.path.exists(YT_CSV):
        with open(YT_CSV, encoding='utf-8-sig', newline='') as f:
            for row in csv.DictReader(f):
                url = (row.get('url') or '').strip()
                try: n = int((row.get('song_no') or '').strip())
                except ValueError: continue
                if url.startswith('http'): res[((row.get('lang') or '').strip().lower(), n)] = url
    return res

def write_youtube_template(datas):
    path = os.path.join(OUT, 'youtube_links_template.csv')
    with open(path, 'w', encoding='utf-8-sig', newline='') as f:
        w = csv.writer(f); w.writerow(['lang', 'song_no', 'title', 'url'])
        for d in datas:
            for x in d['songs']: w.writerow([x['lang_code'], x['song_no'], x['title_en'] or x['title_native'], x.get('youtube_url') or ''])
    print('Song list for adding YouTube links:', path)

# ------------------------------------------------------------------ build one language
def language_row(L, active):
    lead = ('Nine books of Bible lessons in %s%s, with a Teacher’s Guide, workbooks, crafts and games for every lesson.'
            % (L['folder'], '' if L['code'] == 'en' else ' (%s)' % L['native']))
    return dict(code=L['code'], name=L['folder'], native_name=L['native'], glyph=L['glyph'], web_folder=L['folder'],
                hero_lead=lead if active else None, sort_order=L['sort'], active=active)

def build(L, english_titles):
    code = L['code']
    ldir = os.path.join(DOCS, 'SundaySchool_' + L['folder'])
    books = books_of(ldir)
    out = dict(language=language_row(L, bool(books)), books=[], lessons=[], contents=[], songs=[])
    warn = []
    for bn in sorted(books):
        lessons = lessons_of(books[bn])
        if bn not in BOOKS or not lessons: continue
        en_title, folder, ca, cb, icon = BOOKS[bn]
        first = lessons[min(lessons)][1]
        native = None if code == 'en' else (native_book_title(first) or BOOK_TITLES_FALLBACK.get(code, {}).get(bn))
        out['books'].append(dict(lang_code=code, book_no=bn, title_en=en_title, title_native=native, folder=folder,
                                 color_a=ca, color_b=cb, icon=icon, lesson_count=len(lessons)))
        for ln in sorted(lessons):
            folder_title, files = lessons[ln]
            title_en = english_titles.get((bn, ln)) or folder_title
            title = title_en if code == 'en' else lesson_title(files, title_en)
            out['lessons'].append(dict(lang_code=code, book_no=bn, lesson_no=ln, title_native=title, title_en=None if code == 'en' else title_en))
            for kind in KIND_BY_PREFIX.values():
                if kind not in files: warn.append('Book %d lesson %d: no %s file' % (bn, ln, kind)); continue
                body = docx_markdown(files[kind], drop_head=(kind == 'teachers_guide'))
                if body: out['contents'].append(dict(lang_code=code, book_no=bn, lesson_no=ln, kind=kind, body=body))
                else: warn.append('Book %d lesson %d: %s is empty' % (bn, ln, kind))
    links = load_youtube_csv()
    for s in parse_songs(L['songs']):
        out['songs'].append(dict(lang_code=code, song_no=s['no'], title_native=s['title_native'], title_en=s['title_en'],
                                 lyrics_native=s['lyrics_native'], lyrics_en=s['lyrics_en'], youtube_url=links.get((code, s['no'])) or s['youtube_url']))
    print('%-10s books %d  lessons %3d  texts %4d  songs %3d  warnings %d' % (L['folder'], len(out['books']), len(out['lessons']), len(out['contents']), len(out['songs']), len(warn)))
    for w in warn[:8]: print('     ', w)
    if len(warn) > 8: print('      ... %d more' % (len(warn) - 8))
    return out

def english_titles():
    res = {}
    for bn, bdir in books_of(os.path.join(DOCS, 'SundaySchool_English')).items():
        for ln, (title, _) in lessons_of(bdir).items(): res[(bn, ln)] = title
    return res

# ------------------------------------------------------------------ upload
def post(url, key, table, rows, on_conflict):
    if not rows: return
    step = 25 if table == 'lesson_contents' else 200
    for i in range(0, len(rows), step):
        chunk = rows[i:i + step]
        req = urllib.request.Request('%s/rest/v1/%s?on_conflict=%s' % (url, table, on_conflict), data=json.dumps(chunk, ensure_ascii=False).encode('utf-8'), method='POST',
            headers={'apikey': key, 'Authorization': 'Bearer ' + key, 'Content-Type': 'application/json', 'Prefer': 'resolution=merge-duplicates,return=minimal'})
        try: urllib.request.urlopen(req, timeout=120).read()
        except urllib.error.HTTPError as e: sys.exit('Upload to %s failed: %s %s' % (table, e.code, e.read().decode('utf-8', 'replace')[:400]))
    print('  uploaded %-16s %d rows' % (table, len(rows)))

def upload(data):
    url = os.environ.get('SUPABASE_URL', '').rstrip('/'); key = os.environ.get('SUPABASE_SERVICE_KEY', '')
    if not url or not key: sys.exit('Set SUPABASE_URL and SUPABASE_SERVICE_KEY first (see the top of this file).')
    print('Uploading', data['language']['name'])
    post(url, key, 'languages', [data['language']], 'code')
    post(url, key, 'books', data['books'], 'lang_code,book_no')
    post(url, key, 'lessons', data['lessons'], 'lang_code,book_no,lesson_no')
    post(url, key, 'lesson_contents', data['contents'], 'lang_code,book_no,lesson_no,kind')
    post(url, key, 'songs', data['songs'], 'lang_code,song_no')

if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    titles = english_titles()
    built = []
    for L in LANGS:
        if ONLY and L['folder'].lower() not in ONLY: continue
        data = build(L, titles); built.append(data)
        with open(os.path.join(OUT, L['folder'].lower() + '.json'), 'w', encoding='utf-8') as f: json.dump(data, f, ensure_ascii=False, indent=1)
        if UPLOAD: upload(data)
    write_youtube_template(built)
    print('Done.' + ('' if UPLOAD else ' (not uploaded - add --upload to send to Supabase)'))
