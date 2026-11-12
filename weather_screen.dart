import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

/// मौसम — 10 din ka anuman
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool loading = true;
  String? error;
  List<dynamic> days = [];
  Map<String, dynamic>? now;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await Api.get('public/weather', auth: false);
      // backend alag-alag shape de sakta hai — sab sambhal lo
      Map<String, dynamic> w = res;
      if (res['weather'] is Map<String, dynamic>) {
        w = res['weather'] as Map<String, dynamic>;
      }
      final raw = w['days'] ?? w['forecast'] ?? res['days'] ?? res['forecast'];
      setState(() {
        days = (raw is List) ? raw : [];
        now = (w['now'] is Map<String, dynamic>)
            ? w['now'] as Map<String, dynamic>
            : (w['current'] is Map<String, dynamic>
                ? w['current'] as Map<String, dynamic>
                : null);
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  IconData _iconFor(String text) {
    final t = text.toLowerCase();
    if (t.contains('बारिश') || t.contains('rain') || t.contains('बौछार')) {
      return Icons.grain;
    }
    if (t.contains('बादल') || t.contains('cloud')) return Icons.cloud_outlined;
    if (t.contains('आंधी') || t.contains('storm')) return Icons.thunderstorm;
    if (t.contains('कोहरा') || t.contains('fog')) return Icons.foggy;
    return Icons.wb_sunny_outlined;
  }

  String _dayName(dynamic date) {
    final s = date?.toString() ?? '';
    try {
      final d = DateTime.parse(s);
      const names = ['सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'];
      return names[d.weekday - 1];
    } catch (_) {
      return s.length >= 10 ? s.substring(5, 10) : s;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          const SectionTitle('मौसम'),
          NoteBox(error ??
              'तेलहाड़ा मंडी, नालंदा का 10 दिन का अनुमान — बुवाई, सिंचाई और कटाई का फैसला आसान।'),
          if (now != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(_iconFor('${now!['text'] ?? now!['condition'] ?? ''}'),
                        size: 44, color: RgtColors.goldDark),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('अभी का मौसम',
                              style: TextStyle(
                                  fontSize: 12.5, color: RgtColors.grey)),
                          Text(
                              '${now!['temp'] ?? now!['tempC'] ?? '—'}°C'
                              '${(now!['humidity'] ?? '') != '' ? "  ·  नमी ${now!['humidity']}%" : ""}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: RgtColors.green)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (days.isEmpty && error == null)
            const NoteBox('अभी मौसम का डेटा नहीं आया — थोड़ी देर बाद फिर देखें।'),
          ...days.map((d) {
            final m = d as Map<String, dynamic>;
            final text = '${m['text'] ?? m['condition'] ?? ''}';
            final maxT = m['max'] ?? m['maxC'] ?? m['tempMax'];
            final minT = m['min'] ?? m['minC'] ?? m['tempMin'];
            final rain = m['rain'] ?? m['rainMm'] ?? m['precip'];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(_iconFor(text),
                    color: RgtColors.green, size: 26),
                title: Text('${_dayName(m['date'] ?? m['day'])}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(
                    text.isNotEmpty ? text : '—',
                    style: const TextStyle(fontSize: 12)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${maxT ?? '—'}° / ${minT ?? '—'}°',
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w700)),
                    if (rain != null)
                      Text('बारिश ${rain}mm',
                          style: const TextStyle(
                              fontSize: 10.5, color: RgtColors.grey)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
