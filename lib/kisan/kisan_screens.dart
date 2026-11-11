import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/api.dart';
import '../core/config.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

/// भाव — default tab
class RatesScreen extends StatefulWidget {
  const RatesScreen({super.key});
  @override
  State<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
  List<dynamic> rates = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Api.get('public/rates', auth: false);
      setState(() {
        rates = (res['rates'] ?? []) as List<dynamic>;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
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
          const SectionTitle('आज का भाव'),
          NoteBox(error ?? 'भाव रोज़ सुबह 5:00 बजे अपडेट होते हैं।'),
          ...rates.map((r) {
            final m = r as Map<String, dynamic>;
            final min = m['minRate'] ?? m['rate'] ?? 0;
            final max = m['maxRate'] ?? 0;
            final range = (max is num && max > 0) ? '₹$min – ₹$max' : '₹$min';
            return Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    const Icon(Icons.grass, color: RgtColors.greenLight),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          m['cropNameHindi']?.toString() ??
                              (m['cropId']?.toString() ?? ''),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    Text('$range / क्विंटल',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: RgtColors.green)),
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

/// किसानी — Gemini AI
class KisaaniScreen extends StatefulWidget {
  const KisaaniScreen({super.key});
  @override
  State<KisaaniScreen> createState() => _KisaaniScreenState();
}

class _KisaaniScreenState extends State<KisaaniScreen> {
  static const crops = ['धान', 'गेहूँ', 'मक्का', 'आलू', 'सरसों', 'चना', 'अरहर',
    'मूंग', 'उड़द', 'मसूर', 'जौ', 'प्याज', 'टमाटर', 'गन्ना'];
  String crop = 'धान';
  final _q = TextEditingController();
  bool loading = false;
  Map<String, dynamic>? result;
  String? error;

  Future<void> _search() async {
    if (_q.text.trim().length < 3) return;
    setState(() {
      loading = true;
      error = null;
      result = null;
    });
    try {
      final res = await Api.get(
          'public/kisaani?crop=${Uri.encodeComponent(crop)}&q=${Uri.encodeComponent(_q.text.trim())}',
          auth: false);
      setState(() {
        result = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        const SectionTitle('किसानी — फसल की जानकारी'),
        const NoteBox(
            'फसल चुनें और समस्या लिखें — Google + Gemini AI से सही जानकारी, सलाह और फोटो।'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('फसल चुनें',
                    style: TextStyle(fontSize: 12.5, color: RgtColors.grey)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: crop,
                  items: crops
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => crop = v ?? 'धान'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _q,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'अपनी समस्या लिखें… जैसे: पत्ती पीली हो रही है',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: loading ? null : _search,
                  icon: const Icon(Icons.search),
                  label: Text(loading ? 'खोज रहे हैं…' : '🔍 जानकारी खोजें'),
                ),
              ],
            ),
          ),
        ),
        if (error != null) NoteBox(error!),
        if (result != null) _resultView(result!),
      ],
    );
  }

  Widget _resultView(Map<String, dynamic> r) {
    final points = (r['points'] ?? []) as List<dynamic>;
    final sources = (r['sources'] ?? []) as List<dynamic>;
    final engine = r['engine']?.toString() ?? '';
    final img = (r['imageUrl'] ?? '').toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('🌱 ${r['title'] ?? crop}${engine == 'GEMINI' ? '  ·  AI' : ''}'),
        if (img.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(img,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox()),
          ),
        if ((r['summary']?.toString() ?? '').isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child:
                  Text(r['summary'].toString(), style: const TextStyle(fontSize: 13.5)),
            ),
          ),
        if (points.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('मुख्य बातें',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: RgtColors.green)),
                  const SizedBox(height: 6),
                  ...points.map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child:
                            Text('• $p', style: const TextStyle(fontSize: 13.5)),
                      )),
                ],
              ),
            ),
          ),
        if ((r['tip']?.toString() ?? '').isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8EC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCEE4C8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 RGT की सलाह',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: RgtColors.green)),
                const SizedBox(height: 4),
                Text(r['tip'].toString(), style: const TextStyle(fontSize: 13.5)),
              ],
            ),
          ),
        if (sources.isNotEmpty) ...[
          const SectionTitle('स्रोत'),
          ...sources.map((s) {
            final m = s as Map<String, dynamic>;
            return ListTile(
              dense: true,
              leading: const Icon(Icons.link, size: 18),
              title: Text(m['title']?.toString() ?? '',
                  style: const TextStyle(fontSize: 12.5)),
              onTap: () async {
                final u = Uri.tryParse(m['url']?.toString() ?? '');
                if (u != null) await launchUrl(u, mode: LaunchMode.externalApplication);
              },
            );
          }),
        ],
      ],
    );
  }
}

/// 🧾 रसीद — token/reference se status
class ReceiptStatusScreen extends StatefulWidget {
  const ReceiptStatusScreen({super.key});
  @override
  State<ReceiptStatusScreen> createState() => _ReceiptStatusScreenState();
}

class _ReceiptStatusScreenState extends State<ReceiptStatusScreen> {
  final _ref = TextEditingController();
  Map<String, dynamic>? data;
  String? error;
  bool loading = false;

  Future<void> _find() async {
    if (_ref.text.trim().length < 3) return;
    setState(() {
      loading = true;
      error = null;
      data = null;
    });
    try {
      final res = await Api.get(
          'public/receipt/status?ref=${Uri.encodeComponent(_ref.text.trim())}',
          auth: false);
      setState(() {
        data = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = data?['receipt'] as Map<String, dynamic>?;
    final paid = data?['paid'] == true;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        const SectionTitle('मेरी रसीद देखें'),
        const NoteBox(
            'टोकन नंबर या रेफ़रेंस नंबर डालें — माल कहाँ तक पहुँचा और भुगतान हुआ या नहीं।'),
        TextField(
          controller: _ref,
          decoration: const InputDecoration(hintText: 'टोकन / रेफ़रेंस नंबर'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: loading ? null : _find,
          icon: const Icon(Icons.search),
          label: Text(loading ? 'देख रहे हैं…' : '🔎 रसीद देखें'),
        ),
        if (error != null) ...[const SizedBox(height: 10), NoteBox(error!)],
        if (r != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: paid ? const Color(0xFFE2F5E8) : const Color(0xFFFFF6E2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: paid ? const Color(0xFF96C8A5) : const Color(0xFFDCC38C)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${paid ? "✅" : "⏳"} ${data?['stage'] ?? ""}',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: paid
                            ? const Color(0xFF125A2D)
                            : const Color(0xFF78500A))),
                const SizedBox(height: 4),
                Text(
                    'रेफ़रेंस: ${r['finalReceiptId'] ?? r['receiptId'] ?? ""}   ·   टोकन: ${r['token'] ?? "—"}',
                    style: const TextStyle(fontSize: 11.5, color: RgtColors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                children: [
                  InfoRow('किसान', r['kisanName']?.toString() ?? '—'),
                  InfoRow('पता', r['address']?.toString() ?? '—'),
                  InfoRow('अनाज', r['crop']?.toString() ?? '—'),
                  InfoRow('बोरी', '${r['bora'] ?? 0}'),
                  InfoRow('वज़न', '${r['weightQuintal'] ?? 0} क्विंटल'),
                  if ((r['rate'] ?? 0) != 0)
                    InfoRow('भाव', '₹${r['rate']} / क्विंटल'),
                  if ((r['gross'] ?? 0) != 0) ...[
                    InfoRow('कुल कीमत', '₹${r['gross']}'),
                    InfoRow('कुल खर्च', '₹${r['totalKharch'] ?? 0}'),
                  ],
                  if ((r['payable'] ?? 0) != 0)
                    InfoRow('भुगतान',
                        '₹${r['payable']}${paid ? "  (मिल गया)" : "  (बाकी)"}',
                        bold: true),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// शुभ
class ShubhScreen extends StatelessWidget {
  const ShubhScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        const SectionTitle('शुभ से बात करें'),
        const NoteBox('शुभ हमारा AI सहायक है — भाव, गद्दी, सौदा, सब पूछ सकते हैं। '
            'वह खुद कॉल नहीं करता, आप कॉल करें।'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset('assets/images/logo_round.png', height: 84),
                const SizedBox(height: 10),
                const Text('08064269488',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: RgtColors.green)),
                const SizedBox(height: 4),
                const Text('सुबह 8:00 से शाम 6:00 तक',
                    style: TextStyle(fontSize: 12, color: RgtColors.grey)),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => dialNumber(AppConfig.shubhPhone),
                  icon: const Icon(Icons.call),
                  label: const Text('📞 शुभ को कॉल करें'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// पूछताछ
class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});
  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _village = TextEditingController();
  final _crop = TextEditingController();
  final _qty = TextEditingController();
  bool sending = false;
  String? msg;

  Future<void> _send() async {
    if (_name.text.trim().isEmpty || _mobile.text.trim().length < 10) {
      setState(() => msg = 'नाम और 10 अंकों का मोबाइल भरें।');
      return;
    }
    setState(() {
      sending = true;
      msg = null;
    });
    try {
      await Api.post('public/enquiry', {
        'name': _name.text.trim(),
        'mobile': _mobile.text.trim(),
        'village': _village.text.trim(),
        'crop': _crop.text.trim(),
        'quantity': _qty.text.trim(),
      }, auth: false);
      setState(() {
        msg = '✅ पूछताछ भेज दी गई — हमारी टीम कॉल करेगी।';
        sending = false;
      });
      _name.clear();
      _mobile.clear();
      _village.clear();
      _crop.clear();
      _qty.clear();
    } catch (e) {
      setState(() {
        msg = 'भेज नहीं पाए: $e';
        sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        const SectionTitle('पूछताछ'),
        const NoteBox('अपना नाम, मोबाइल और अनाज भरें — गद्दी की टीम आपको कॉल करेगी।'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              children: [
                TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'आपका नाम')),
                const SizedBox(height: 10),
                TextField(
                    controller: _mobile,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'मोबाइल नंबर')),
                const SizedBox(height: 10),
                TextField(
                    controller: _village,
                    decoration: const InputDecoration(labelText: 'गाँव / पता')),
                const SizedBox(height: 10),
                TextField(
                    controller: _crop,
                    decoration:
                        const InputDecoration(labelText: 'अनाज (जैसे धान)')),
                const SizedBox(height: 10),
                TextField(
                    controller: _qty,
                    decoration: const InputDecoration(
                        labelText: 'मात्रा (क्विंटल/बोरी)')),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: sending ? null : _send,
                  child: Text(sending ? 'भेज रहे हैं…' : 'पूछताछ भेजें'),
                ),
              ],
            ),
          ),
        ),
        if (msg != null) NoteBox(msg!),
      ],
    );
  }
}

/// विज्ञापन
class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});
  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  List<dynamic> ads = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Api.get('public/ads', auth: false);
      setState(() {
        ads = (res['ads'] ?? []) as List<dynamic>;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (ads.isEmpty) return const Center(child: Text('अभी कोई विज्ञापन नहीं'));
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: ads.map((a) {
        final m = a as Map<String, dynamic>;
        final img = (m['imageUrl'] ?? m['posterUrl'] ?? '').toString();
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // poster PORTRAIT me — poora dikhe, kate nahi
              if (img.isNotEmpty)
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    color: const Color(0xFFF3F5EF),
                    width: double.infinity,
                    child: Image.network(
                      img,
                      fit: BoxFit.contain, // poora poster andar
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined,
                            size: 40, color: RgtColors.grey),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m['title']?.toString() ?? '',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    if ((m['description'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(m['description'].toString(),
                          style: const TextStyle(fontSize: 12.5)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// सहायता
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        const SectionTitle('सहायता'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InfoRow('कस्टमर सपोर्ट', AppConfig.supportPhone, bold: true),
                const InfoRow('गद्दी खुलने का समय', 'सभी दिन — सुबह 8:00 से शाम 6:00'),
                const InfoRow('पता', AppConfig.address),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () => dialNumber(AppConfig.supportPhone),
                  icon: const Icon(Icons.call),
                  label: const Text('📞 कस्टमर सपोर्ट'),
                ),
              ],
            ),
          ),
        ),
        const SectionTitle('मालिक'),
        _owner('assets/images/owner_rajni.jpg', 'रजनी कांत', 'B.Tech, MBA'),
        _owner('assets/images/owner_ravi.jpg', 'रवि कांत', 'BTS, MBA'),
        const SectionTitle('गद्दी'),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset('assets/images/gaddi2.jpg', fit: BoxFit.cover),
        ),
        const SizedBox(height: 10),
        const NoteBox(AppConfig.about),
      ],
    );
  }

  Widget _owner(String img, String name, String edu) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(img, width: 64, height: 64, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: RgtColors.green)),
                    Text('शिक्षा: $edu', style: const TextStyle(fontSize: 13)),
                    const Text('फौजदार साह के पौत्र · महेश जी के पुत्र',
                        style: TextStyle(fontSize: 12, color: RgtColors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
