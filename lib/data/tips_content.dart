import 'tips_model.dart';
import 'tips_part_a.dart';
import 'tips_part_b.dart';
import 'tips_part_c.dart';
import 'tips_part_d.dart';

export 'tips_model.dart';

/// "Tips to conduct Sunday school" in all 11 languages (the same full content in each).
/// Languages shown in the drop-down at the top of the Tips page: (code, label).
const tipLanguages = <(String, String)>[
  ('en', 'English'),
  ('ta', 'தமிழ் (Tamil)'),
  ('te', 'తెలుగు (Telugu)'),
  ('kn', 'ಕನ್ನಡ (Kannada)'),
  ('bn', 'বাংলা (Bengali)'),
  ('gu', 'ગુજરાતી (Gujarati)'),
  ('ml', 'മലയാളം (Malayalam)'),
  ('mr', 'मराठी (Marathi)'),
  ('hi', 'हिन्दी (Hindi)'),
  ('or', 'ଓଡ଼ିଆ (Odia)'),
  ('ur', 'اردو (Urdu)'),
];

final Map<String, TipsContent> _all = {...tipsPartA, ...tipsPartB, ...tipsPartC, ...tipsPartD};

TipsContent tipsFor(String code) => _all[code] ?? _all['en']!;
