/// Interface text of the language landing page in each language (regional script), so that the page reads
/// in the reader's own language. English is only used for the small "<Language> - Bible Lessons for Kids & Children" line.
class UiStrings {
  final String kicker, tail, lead, books, lessons, resources, search, choose, book, start, cont, completed, browse, none;
  const UiStrings({
    required this.kicker, required this.tail, required this.lead, required this.books, required this.lessons, required this.resources,
    required this.search, required this.choose, required this.book, required this.start, required this.cont,
    required this.completed, required this.browse, required this.none,
  });

  String bookLabel(int n) => book.replaceAll('{n}', '$n');
  String startLabel(int n) => start.replaceAll('{n}', '$n');
  String continueLabel(int n) => cont.replaceAll('{n}', '$n');
  String completedLabel(int a, int b) => completed.replaceAll('{a}', '$a').replaceAll('{b}', '$b');
  String browseLabel(int n) => browse.replaceAll('{n}', '$n');
  String leadFor(String name) => lead.replaceAll('{name}', name);

  static const english = UiStrings(
    kicker: 'ABBA Sunday School', tail: 'Kids & Children',
    lead: 'Bible lessons in {name}, with a Teacher’s Guide, workbooks, crafts and games for every lesson.',
    books: 'Books', lessons: 'Lessons', resources: 'Resources each', search: 'Search a lesson, e.g. Noah, David, Jesus...',
    choose: 'Choose a Book', book: 'Book {n}', start: 'Start Lesson {n}', cont: 'Continue Lesson {n}',
    completed: '{a} / {b} completed', browse: 'Browse all {n} lessons', none: 'No lessons match your search.',
  );

  static UiStrings of(String code) => _all[code] ?? english;

  static const _all = <String, UiStrings>{
    'hi': UiStrings(
      kicker: 'ABBA Sunday School', tail: 'बच्चों के लिए बाइबल पाठ',
      lead: '{name} में बाइबल पाठों की नौ पुस्तकें, हर पाठ के लिए शिक्षक मार्गदर्शिका, कार्यपुस्तिकाएँ, शिल्प और खेल सहित।',
      books: 'पुस्तकें', lessons: 'पाठ', resources: 'प्रत्येक के संसाधन', search: 'कोई पाठ खोजें, जैसे नूह, दाऊद, यीशु...',
      choose: 'एक पुस्तक चुनें', book: 'पुस्तक {n}', start: 'पाठ {n} शुरू करें', cont: 'पाठ {n} जारी रखें',
      completed: '{a} / {b} पूर्ण', browse: 'सभी {n} पाठ देखें', none: 'आपकी खोज से कोई पाठ मेल नहीं खाता।'),
    'mr': UiStrings(
      kicker: 'ABBA Sunday School', tail: 'मुलांसाठी बायबल धडे',
      lead: '{name} मध्ये बायबल धड्यांची नऊ पुस्तके, प्रत्येक धड्यासाठी शिक्षक मार्गदर्शिका, कार्यपुस्तिका, हस्तकला आणि खेळांसह.',
      books: 'पुस्तके', lessons: 'धडे', resources: 'प्रत्येकी साधने', search: 'धडा शोधा, उदा. नोहा, दावीद, येशू...',
      choose: 'एक पुस्तक निवडा', book: 'पुस्तक {n}', start: 'धडा {n} सुरू करा', cont: 'धडा {n} पुढे चालू ठेवा',
      completed: '{a} / {b} पूर्ण', browse: 'सर्व {n} धडे पहा', none: 'तुमच्या शोधाशी जुळणारा धडा नाही.'),
    'bn': UiStrings(
      kicker: 'ABBA Sunday School', tail: 'শিশু ও ছোটদের জন্য বাইবেল পাঠ',
      lead: '{name} ভাষায় বাইবেল পাঠের নয়টি বই, প্রতিটি পাঠের জন্য শিক্ষক নির্দেশিকা, ওয়ার্কবুক, হস্তশিল্প ও খেলা সহ।',
      books: 'বই', lessons: 'পাঠ', resources: 'প্রতিটির সম্পদ', search: 'পাঠ খুঁজুন, যেমন নোহ, দায়ূদ, যীশু...',
      choose: 'একটি বই বেছে নিন', book: 'বই {n}', start: 'পাঠ {n} শুরু করুন', cont: 'পাঠ {n} চালিয়ে যান',
      completed: '{a} / {b} সম্পন্ন', browse: 'সব {n}টি পাঠ দেখুন', none: 'আপনার অনুসন্ধানের সঙ্গে কোনো পাঠ মেলেনি।'),
    'gu': UiStrings(
      kicker: 'ABBA Sunday School', tail: 'બાળકો માટે બાઇબલ પાઠ',
      lead: '{name} માં બાઇબલ પાઠોના નવ પુસ્તકો, દરેક પાઠ માટે શિક્ષક માર્ગદર્શિકા, વર્કબુક, હસ્તકલા અને રમતો સાથે.',
      books: 'પુસ્તકો', lessons: 'પાઠ', resources: 'દરેકના સંસાધનો', search: 'પાઠ શોધો, જેમ કે નૂહ, દાઉદ, ઈસુ...',
      choose: 'એક પુસ્તક પસંદ કરો', book: 'પુસ્તક {n}', start: 'પાઠ {n} શરૂ કરો', cont: 'પાઠ {n} ચાલુ રાખો',
      completed: '{a} / {b} પૂર્ણ', browse: 'બધા {n} પાઠ જુઓ', none: 'તમારી શોધ સાથે કોઈ પાઠ મેળ ખાતો નથી.'),
    'ta': UiStrings(
      kicker: 'ABBA Sunday School', tail: 'சிறுவர்களுக்கான வேதாகம பாடங்கள்',
      lead: '{name} மொழியில் ஒன்பது வேதாகம பாடப் புத்தகங்கள்; ஒவ்வொரு பாடத்திற்கும் ஆசிரியர் வழிகாட்டி, பணிப்புத்தகங்கள், கைவினைகள் மற்றும் விளையாட்டுகளுடன்.',
      books: 'புத்தகங்கள்', lessons: 'பாடங்கள்', resources: 'ஒவ்வொன்றிலும் வளங்கள்', search: 'பாடத்தைத் தேடுங்கள், எ.கா. நோவா, தாவீது, இயேசு...',
      choose: 'ஒரு புத்தகத்தைத் தேர்ந்தெடுக்கவும்', book: 'புத்தகம் {n}', start: 'பாடம் {n} தொடங்கவும்', cont: 'பாடம் {n} தொடரவும்',
      completed: '{a} / {b} முடிந்தது', browse: '{n} பாடங்களையும் பார்க்க', none: 'உங்கள் தேடலுக்குப் பொருந்தும் பாடம் இல்லை.'),
    'te': UiStrings(
      kicker: 'ABBA Sunday School', tail: 'పిల్లల కోసం బైబిల్ పాఠాలు',
      lead: '{name} లో తొమ్మిది బైబిల్ పాఠ పుస్తకాలు, ప్రతి పాఠానికి ఉపాధ్యాయ మార్గదర్శి, వర్క్‌బుక్‌లు, హస్తకళలు మరియు ఆటలతో.',
      books: 'పుస్తకాలు', lessons: 'పాఠాలు', resources: 'ప్రతిదానిలో వనరులు', search: 'పాఠం వెతకండి, ఉదా. నోవహు, దావీదు, యేసు...',
      choose: 'ఒక పుస్తకాన్ని ఎంచుకోండి', book: 'పుస్తకం {n}', start: 'పాఠం {n} ప్రారంభించండి', cont: 'పాఠం {n} కొనసాగించండి',
      completed: '{a} / {b} పూర్తయ్యాయి', browse: 'మొత్తం {n} పాఠాలు చూడండి', none: 'మీ శోధనకు సరిపడే పాఠాలు లేవు.'),
    'kn': UiStrings(
      kicker: 'ABBA Sunday School', tail: 'ಮಕ್ಕಳಿಗಾಗಿ ಬೈಬಲ್ ಪಾಠಗಳು',
      lead: '{name} ಭಾಷೆಯಲ್ಲಿ ಒಂಬತ್ತು ಬೈಬಲ್ ಪಾಠ ಪುಸ್ತಕಗಳು, ಪ್ರತಿ ಪಾಠಕ್ಕೂ ಶಿಕ್ಷಕರ ಮಾರ್ಗದರ್ಶಿ, ಕಾರ್ಯಪುಸ್ತಕಗಳು, ಕರಕುಶಲ ಮತ್ತು ಆಟಗಳೊಂದಿಗೆ.',
      books: 'ಪುಸ್ತಕಗಳು', lessons: 'ಪಾಠಗಳು', resources: 'ಪ್ರತಿಯೊಂದರಲ್ಲಿ ಸಂಪನ್ಮೂಲಗಳು', search: 'ಪಾಠ ಹುಡುಕಿ, ಉದಾ. ನೋಹ, ದಾವೀದ, ಯೇಸು...',
      choose: 'ಒಂದು ಪುಸ್ತಕವನ್ನು ಆರಿಸಿ', book: 'ಪುಸ್ತಕ {n}', start: 'ಪಾಠ {n} ಆರಂಭಿಸಿ', cont: 'ಪಾಠ {n} ಮುಂದುವರಿಸಿ',
      completed: '{a} / {b} ಪೂರ್ಣ', browse: 'ಎಲ್ಲಾ {n} ಪಾಠಗಳನ್ನು ನೋಡಿ', none: 'ನಿಮ್ಮ ಹುಡುಕಾಟಕ್ಕೆ ಹೊಂದುವ ಪಾಠಗಳಿಲ್ಲ.'),
    'ml': UiStrings(
      kicker: 'ABBA Sunday School', tail: 'കുട്ടികൾക്കുള്ള ബൈബിൾ പാഠങ്ങൾ',
      lead: '{name} ഭാഷയിൽ ഒമ്പത് ബൈബിൾ പാഠ പുസ്തകങ്ങൾ, ഓരോ പാഠത്തിനും അധ്യാപക ഗൈഡ്, വർക്ക്ബുക്കുകൾ, കരകൗശലങ്ങൾ, കളികൾ എന്നിവയോടെ.',
      books: 'പുസ്തകങ്ങൾ', lessons: 'പാഠങ്ങൾ', resources: 'ഓരോന്നിലും വിഭവങ്ങൾ', search: 'പാഠം തിരയുക, ഉദാ. നോഹ, ദാവീദ്, യേശു...',
      choose: 'ഒരു പുസ്തകം തിരഞ്ഞെടുക്കുക', book: 'പുസ്തകം {n}', start: 'പാഠം {n} ആരംഭിക്കുക', cont: 'പാഠം {n} തുടരുക',
      completed: '{a} / {b} പൂർത്തിയായി', browse: 'എല്ലാ {n} പാഠങ്ങളും കാണുക', none: 'നിങ്ങളുടെ തിരയലിന് യോജിച്ച പാഠങ്ങളില്ല.'),
    'or': UiStrings(
      kicker: 'ABBA Sunday School', tail: 'ପିଲାମାନଙ୍କ ପାଇଁ ବାଇବଲ ପାଠ',
      lead: '{name} ଭାଷାରେ ବାଇବଲ ପାଠର ନଅଟି ପୁସ୍ତକ, ପ୍ରତ୍ୟେକ ପାଠ ପାଇଁ ଶିକ୍ଷକ ମାର୍ଗଦର୍ଶିକା, ୱାର୍କବୁକ୍, ହସ୍ତଶିଳ୍ପ ଏବଂ ଖେଳ ସହିତ।',
      books: 'ପୁସ୍ତକ', lessons: 'ପାଠ', resources: 'ପ୍ରତ୍ୟେକରେ ସମ୍ବଳ', search: 'ପାଠ ଖୋଜନ୍ତୁ, ଯେପରି ନୂହ, ଦାଉଦ, ଯୀଶୁ...',
      choose: 'ଗୋଟିଏ ପୁସ୍ତକ ବାଛନ୍ତୁ', book: 'ପୁସ୍ତକ {n}', start: 'ପାଠ {n} ଆରମ୍ଭ କରନ୍ତୁ', cont: 'ପାଠ {n} ଜାରି ରଖନ୍ତୁ',
      completed: '{a} / {b} ସମ୍ପୂର୍ଣ୍ଣ', browse: 'ସମସ୍ତ {n}ଟି ପାଠ ଦେଖନ୍ତୁ', none: 'ଆପଣଙ୍କ ସନ୍ଧାନ ସହିତ କୌଣସି ପାଠ ମେଳ ଖାଉନାହିଁ।'),
    'ur': UiStrings(
      kicker: 'ABBA Sunday School', tail: 'بچوں کے لیے بائبل کے اسباق',
      lead: '{name} میں بائبل کے اسباق کی نو کتابیں، ہر سبق کے لیے استاد کی رہنما، ورک بک، دستکاری اور کھیلوں کے ساتھ۔',
      books: 'کتابیں', lessons: 'اسباق', resources: 'ہر ایک میں وسائل', search: 'سبق تلاش کریں، مثلاً نوح، داؤد، یسوع...',
      choose: 'ایک کتاب منتخب کریں', book: 'کتاب {n}', start: 'سبق {n} شروع کریں', cont: 'سبق {n} جاری رکھیں',
      completed: '{a} / {b} مکمل', browse: 'تمام {n} اسباق دیکھیں', none: 'آپ کی تلاش سے کوئی سبق میل نہیں کھاتا۔'),
    'zh': UiStrings(
      kicker: 'ABBA Sunday School', tail: "儿童圣经课程",
      lead: "{name}圣经课程共九册，每一课都配有教师指南、练习册、手工和游戏。",
      books: "册", lessons: "课", resources: "每课资源", search: "搜索课程，例如：挪亚、大卫、耶稣...",
      choose: "选择一册", book: "第 {n} 册", start: "开始第 {n} 课", cont: "继续第 {n} 课",
      completed: "已完成 {a} / {b}", browse: "浏览全部 {n} 课", none: "没有符合搜索条件的课程。"),
    'es': UiStrings(
      kicker: 'ABBA Sunday School', tail: "Lecciones bíblicas para niños",
      lead: "Lecciones bíblicas en {name}, con guía del maestro, cuadernos de trabajo, manualidades y juegos para cada lección.",
      books: "Libros", lessons: "Lecciones", resources: "Recursos por lección", search: "Busca una lección, p. ej. Noé, David, Jesús...",
      choose: "Elige un libro", book: "Libro {n}", start: "Comenzar la lección {n}", cont: "Continuar la lección {n}",
      completed: "{a} / {b} completadas", browse: "Ver las {n} lecciones", none: "Ninguna lección coincide con tu búsqueda."),
    'ar': UiStrings(
      kicker: 'ABBA Sunday School', tail: "دروس الكتاب المقدس للأطفال",
      lead: "دروس الكتاب المقدس باللغة {name}، مع دليل المعلم وكراسات التمارين والأشغال اليدوية والألعاب لكل درس.",
      books: "الكتب", lessons: "الدروس", resources: "موارد لكل درس", search: "ابحث عن درس، مثل نوح وداود ويسوع...",
      choose: "اختر كتابًا", book: "الكتاب {n}", start: "ابدأ الدرس {n}", cont: "تابع الدرس {n}",
      completed: "اكتمل {a} / {b}", browse: "تصفّح جميع الدروس ({n})", none: "لا توجد دروس مطابقة لبحثك."),
    'fr': UiStrings(
      kicker: 'ABBA Sunday School', tail: "Leçons bibliques pour enfants",
      lead: "Leçons bibliques en {name}, avec un guide de l’enseignant, des cahiers d’activités, des bricolages et des jeux pour chaque leçon.",
      books: "Livres", lessons: "Leçons", resources: "Ressources par leçon", search: "Rechercher une leçon, p. ex. Noé, David, Jésus...",
      choose: "Choisissez un livre", book: "Livre {n}", start: "Commencer la leçon {n}", cont: "Continuer la leçon {n}",
      completed: "{a} / {b} terminées", browse: "Voir les {n} leçons", none: "Aucune leçon ne correspond à votre recherche."),
    'pt': UiStrings(
      kicker: 'ABBA Sunday School', tail: "Lições bíblicas para crianças",
      lead: "Lições bíblicas em {name}, com guia do professor, cadernos de atividades, trabalhos manuais e jogos para cada lição.",
      books: "Livros", lessons: "Lições", resources: "Recursos por lição", search: "Procure uma lição, por exemplo: Noé, Davi, Jesus...",
      choose: "Escolha um livro", book: "Livro {n}", start: "Começar a lição {n}", cont: "Continuar a lição {n}",
      completed: "{a} / {b} concluídas", browse: "Ver todas as {n} lições", none: "Nenhuma lição corresponde à sua busca."),
    'id': UiStrings(
      kicker: 'ABBA Sunday School', tail: "Pelajaran Alkitab untuk Anak-anak",
      lead: "Pelajaran Alkitab dalam {name}, lengkap dengan Panduan Guru, buku kerja, prakarya, dan permainan untuk setiap pelajaran.",
      books: "Buku", lessons: "Pelajaran", resources: "Sumber daya tiap pelajaran", search: "Cari pelajaran, mis. Nuh, Daud, Yesus...",
      choose: "Pilih Sebuah Buku", book: "Buku {n}", start: "Mulai Pelajaran {n}", cont: "Lanjutkan Pelajaran {n}",
      completed: "{a} / {b} selesai", browse: "Lihat semua {n} pelajaran", none: "Tidak ada pelajaran yang cocok dengan pencarian Anda."),
    'ru': UiStrings(
      kicker: 'ABBA Sunday School', tail: "Библейские уроки для детей",
      lead: "Библейские уроки на языке «{name}»: к каждому уроку — руководство для учителя, рабочие тетради, поделки и игры.",
      books: "Книги", lessons: "Уроки", resources: "Материалов к каждому уроку", search: "Найдите урок, например: Ной, Давид, Иисус...",
      choose: "Выберите книгу", book: "Книга {n}", start: "Начать урок {n}", cont: "Продолжить урок {n}",
      completed: "Пройдено: {a} / {b}", browse: "Показать все уроки ({n})", none: "Нет уроков, соответствующих вашему запросу."),
    'de': UiStrings(
      kicker: 'ABBA Sunday School', tail: "Bibellektionen für Kinder",
      lead: "Bibellektionen auf {name}, mit Lehrerhandbuch, Arbeitsheften, Bastelideen und Spielen zu jeder Lektion.",
      books: "Bücher", lessons: "Lektionen", resources: "Materialien je Lektion", search: "Lektion suchen, z. B. Noah, David, Jesus...",
      choose: "Wähle ein Buch", book: "Buch {n}", start: "Lektion {n} beginnen", cont: "Lektion {n} fortsetzen",
      completed: "{a} / {b} abgeschlossen", browse: "Alle {n} Lektionen ansehen", none: "Keine Lektion entspricht deiner Suche."),
    'ja': UiStrings(
      kicker: 'ABBA Sunday School', tail: "子ども向け聖書レッスン",
      lead: "{name}で学ぶ聖書レッスン。各レッスンに教師用ガイド、ワークブック、工作、ゲームがそろっています。",
      books: "巻", lessons: "レッスン", resources: "各レッスンの教材", search: "レッスンを検索（例：ノア、ダビデ、イエス）...",
      choose: "本を選ぶ", book: "第{n}巻", start: "レッスン{n}を始める", cont: "レッスン{n}を続ける",
      completed: "{a} / {b} 完了", browse: "全{n}レッスンを見る", none: "検索に一致するレッスンはありません。"),
  };
}
