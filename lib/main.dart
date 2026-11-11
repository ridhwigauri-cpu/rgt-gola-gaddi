import 'package:flutter/material.dart';
import 'core/config.dart';
import 'kisan/kisan_app.dart';
import 'admin/admin_app.dart';

///   flutter build apk --flavor kisan --dart-define=APP=kisan
///   flutter build apk --flavor admin --dart-define=APP=admin
void main() {
  runApp(AppConfig.isAdmin ? const AdminApp() : const KisanApp());
}
