/// Anaaj ke naam ke hisaab se symbol (emoji).
class Crops {
  static const Map<String, String> _symbols = {
    'धान': '🌾', 'paddy': '🌾', 'गेहूँ': '🌾', 'wheat': '🌾',
    'मक्का': '🌽', 'maize': '🌽', 'आलू': '🥔', 'potato': '🥔',
    'सरसों': '🌼', 'mustard': '🌼', 'चना': '🫘', 'chana': '🫘',
    'अरहर': '🌿', 'arhar': '🌿', 'मूंग': '🫛', 'moong': '🫛',
    'उड़द': '🫘', 'urad': '🫘', 'मसूर': '🫘', 'masoor': '🫘',
    'जौ': '🌾', 'barley': '🌾', 'प्याज': '🧅', 'onion': '🧅',
    'टमाटर': '🍅', 'tomato': '🍅', 'गन्ना': '🎋', 'sugarcane': '🎋',
  };

  static String symbol(String? cropId, String? cropNameHindi) {
    final id = (cropId ?? '').trim().toLowerCase();
    final hi = (cropNameHindi ?? '').trim();
    if (_symbols.containsKey(hi)) return _symbols[hi]!;
    if (_symbols.containsKey(id)) return _symbols[id]!;
    for (final e in _symbols.entries) {
      if (hi.contains(e.key) || id.contains(e.key)) return e.value;
    }
    return '🌾';
  }
}
