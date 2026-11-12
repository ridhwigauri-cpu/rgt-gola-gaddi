import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiException implements Exception {
  final int code;
  final String message;
  ApiException(this.code, this.message);
  @override
  String toString() => message;
}

class Api {
  static String? _token;

  static void setToken(String? t) => _token = t;
  static String? get token => _token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<Map<String, dynamic>> get(String path, {bool auth = true}) async {
    final res = await http
        .get(Uri.parse('${AppConfig.baseUrl}/$path'), headers: auth ? _headers : {})
        .timeout(const Duration(seconds: 60));
    return _parse(res);
  }

  static Future<Map<String, dynamic>> post(String path, Map body,
      {bool auth = true}) async {
    final res = await http
        .post(Uri.parse('${AppConfig.baseUrl}/$path'),
            headers: auth ? _headers : {'Content-Type': 'application/json'},
            body: jsonEncode(body))
        .timeout(const Duration(seconds: 90));
    return _parse(res);
  }

  static Future<Map<String, dynamic>> patch(String path, Map body) async {
    final res = await http
        .patch(Uri.parse('${AppConfig.baseUrl}/$path'),
            headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 60));
    return _parse(res);
  }

  static Map<String, dynamic> _parse(http.Response res) {
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}
    if (res.statusCode >= 400) {
      throw ApiException(res.statusCode,
          (data['error'] ?? data['message'] ?? 'सर्वर से जवाब नहीं आया').toString());
    }
    return data;
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res =
        await post('auth/login', {'email': email, 'password': password}, auth: false);
    final t = res['token']?.toString();
    if (t != null && t.isNotEmpty) setToken(t);
    return res;
  }

  static Future<Map<String, dynamic>> me() => get('auth/me');
}
