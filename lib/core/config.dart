/// RGT Gola Gaddi — ek hi codebase, do apps (flavors).
///
///   flutter build apk --flavor kisan --dart-define=APP=kisan
///   flutter build apk --flavor admin --dart-define=APP=admin
class AppConfig {
  static const String app = String.fromEnvironment('APP', defaultValue: 'kisan');

  static const String baseUrl = String.fromEnvironment(
    'API',
    defaultValue:
        'https://qtephrr6ootx7jzoosqjmecvoe0jrqlh.lambda-url.ap-southeast-2.on.aws',
  );

  /// RGT Gola Gaddi — Mozafrabad, Bihar (Plus Code 65GH+HFG)
  static const double lat = 25.226437;
  static const double lng = 85.178688;

  static const String address = 'RGT Gola Gaddi, TELHARA MANDI, NALANDA BIHAR';
  static const String about =
      'RGT Gola Gaddi (A UNIT OF RIDHWI GAURI TRADERS PVT LTD), '
      'TELHARA MANDI, NALANDA, BIHAR';
  static const String supportPhone = '06111-291499';
  static const String shubhPhone = '08064269488';
  static const String copyright = '© 2026 Ridhwi Gauri Traders Pvt Ltd';

  static bool get isAdmin => app == 'admin';
}
