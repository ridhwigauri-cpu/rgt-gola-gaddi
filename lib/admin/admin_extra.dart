import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/config.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

/// स्टॉक — grain wise + summary
class StockScreen extends StatefulWidget {
  const StockScreen({super.key});
  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  Map<String, dynamic>? stock;
  Map<String, dynamic>? summary;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await Api.get('stock');
      final sm = await Api.get('stock/summary');
      setState(() {
        stock = s;
        summary = sm;
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = (stock?['stock'] ?? []) as List<dynamic>;
    final inMap = summary?['in'] as Map<String, dynamic>?;
    final outMap = summary?['out'] as Map<String, dynamic>?;
    final opening = summary?['opening'] as Map<String, dynamic>?;
    final closing = summary?['closing'] as Map<String, dynamic>?;
    return Scaffold(
      appBar: AppBar(title: const Text('स्टॉक (गोदाम)')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            if (error != null) NoteBox(error!),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('आज का सारांश  (${summary?['date'] ?? ''})',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: RgtColors.green)),
                    const SizedBox(height: 6),
                    InfoRow('पिछला बाकी',
                        '${opening?['bora'] ?? 0} बोरी · ${opening?['weight'] ?? 0} क्विंटल'),
                    InfoRow('आज आया (+)',
                        '${inMap?['bora'] ?? 0} बोरी · ${inMap?['weight'] ?? 0} क्विंटल'),
                    InfoRow('आज बिका (−)',
                        '${outMap?['bora'] ?? 0} बोरी · ${outMap?['weight'] ?? 0} क्विंटल'),
                    InfoRow('बचा स्टॉक',
                        '${closing?['bora'] ?? 0} बोरी · ${closing?['weight'] ?? 0} क्विंटल',
                        bold: true),
                    InfoRow('आज का भुगतान', '₹${inMap?['paid'] ?? 0}'),
                    InfoRow('बाकी भुगतान', '₹${inMap?['unpaid'] ?? 0}'),
                    InfoRow('आज की बिक्री', '₹${outMap?['value'] ?? 0}'),
                  ],
                ),
              ),
            ),
            const SectionTitle('फसल के हिसाब से'),
            ...rows.map((r) {
              final m = r as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 9),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🌾 ${m['crop']}',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: RgtColors.green)),
                      InfoRow('बोरी', '${m['bora']}'),
                      InfoRow('वज़न', '${m['weight']} क्विंटल'),
                      InfoRow('कुल कीमत', '₹${m['value']}'),
                      InfoRow('भुगतान हुआ', '₹${m['paidValue']}'),
                      InfoRow('बाकी', '₹${m['unpaidValue']}'),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (_) =>
                                    GrainDetailScreen(crop: m['crop'].toString())))
                            .then((_) => _load()),
                        child: const Text('एंट्री देखें / भुगतान करें  ›'),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Ek fasl ki entries + भुगतान हो गया
class GrainDetailScreen extends StatefulWidget {
  final String crop;
  const GrainDetailScreen({super.key, required this.crop});
  @override
  State<GrainDetailScreen> createState() => _GrainDetailScreenState();
}

class _GrainDetailScreenState extends State<GrainDetailScreen> {
  List<dynamic> receipts = [];
  List<dynamic> sales = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Api.get('stock/grain?crop=${Uri.encodeComponent(widget.crop)}');
      setState(() {
        receipts = (res['receipts'] ?? []) as List<dynamic>;
        sales = (res['sales'] ?? []) as List<dynamic>;
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  Future<void> _markPaid(String receiptId, num amount) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('भुगतान'),
        content: Text('₹$amount का भुगतान हो गया है?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('नहीं')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('हाँ, हो गया')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Api.patch('receipts/$receiptId/paid', {});
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.crop} — एंट्री')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          if (error != null) NoteBox(error!),
          if (receipts.isEmpty) const NoteBox('इस फसल की कोई एंट्री नहीं।'),
          ...receipts.map((r) {
            final m = r as Map<String, dynamic>;
            final paid = (m['paymentStatus'] ?? 'UNPAID') == 'PAID';
            return Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(m['kisanName']?.toString() ?? 'किसान',
                              style: const TextStyle(
                                  fontSize: 14.5, fontWeight: FontWeight.w700)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: paid
                                ? const Color(0xFFDBF3E2)
                                : const Color(0xFFFFF3D6),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(paid ? '✅ PAID' : '⏳ UNPAID',
                              style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: paid
                                      ? const Color(0xFF12642D)
                                      : const Color(0xFF8C5A0A))),
                        ),
                      ],
                    ),
                    InfoRow('मोबाइल', m['mobile']?.toString() ?? '—'),
                    InfoRow('बोरी / वज़न',
                        '${m['bora'] ?? 0} · ${m['weightQuintal'] ?? 0} क्विंटल'),
                    InfoRow('भाव', '₹${m['rate'] ?? 0} / क्विंटल'),
                    InfoRow('कुल', '₹${m['gross'] ?? 0} − ₹${m['totalKharch'] ?? 0}'),
                    InfoRow('भुगतान', '₹${m['payable'] ?? 0}', bold: true),
                    InfoRow('रेफ़रेंस',
                        m['finalReceiptId']?.toString() ??
                            m['receiptId']?.toString() ??
                            '—'),
                    if (!paid)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: OutlinedButton.icon(
                          onPressed: () => _markPaid(m['receiptId'].toString(),
                              (m['payable'] ?? 0) as num),
                          icon: const Icon(Icons.check_circle_outline, size: 17),
                          label: const Text('✅ भुगतान हो गया'),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          if (sales.isNotEmpty) ...[
            const SectionTitle('बिक्री'),
            ...sales.map((s) {
              final m = s as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 9),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    children: [
                      InfoRow('किसको', m['party']?.toString() ?? '—'),
                      InfoRow('माल',
                          '${m['bora'] ?? 0} बोरी · ${m['weightQuintal'] ?? 0} क्विंटल'),
                      InfoRow('भाव', '₹${m['rate'] ?? 0} / क्विंटल'),
                      InfoRow('रकम', '₹${m['amount'] ?? 0}'),
                      InfoRow('गाड़ी', m['vehicleNo']?.toString() ?? '—'),
                      InfoRow('डिलीवरी', m['deliveryDate']?.toString() ?? '—'),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

/// बिक्री
class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});
  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  static const crops = ['धान', 'गेहूँ', 'मक्का', 'आलू', 'सरसों', 'चना', 'अरहर',
    'मूंग', 'उड़द', 'मसूर', 'जौ', 'प्याज', 'टमाटर', 'गन्ना'];
  String crop = 'धान';
  final _party = TextEditingController();
  final _bora = TextEditingController();
  final _weight = TextEditingController();
  final _rate = TextEditingController();
  final _vehicle = TextEditingController();
  final _delivery = TextEditingController();
  String? msg;
  bool busy = false;

  Future<void> _save() async {
    setState(() {
      busy = true;
      msg = null;
    });
    try {
      final res = await Api.post('sales', {
        'crop': crop,
        'party': _party.text.trim(),
        'bora': double.tryParse(_bora.text) ?? 0,
        'weightQuintal': double.tryParse(_weight.text) ?? 0,
        'rate': double.tryParse(_rate.text) ?? 0,
        'vehicleNo': _vehicle.text.trim(),
        'deliveryDate': _delivery.text.trim(),
      });
      final sale = res['sale'] as Map<String, dynamic>?;
      setState(() {
        msg = '✅ बिक्री दर्ज — ₹${sale?['amount'] ?? 0} · स्टॉक से घट गया';
        busy = false;
      });
    } catch (e) {
      setState(() {
        msg = '$e';
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('बिक्री (लोडर / मिल को)')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          const NoteBox('माल देते ही स्टॉक से घट जाएगा। भाव और गाड़ी नंबर भरें।'),
          DropdownButtonFormField<String>(
            value: crop,
            decoration: const InputDecoration(labelText: 'फसल'),
            items: crops
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => crop = v ?? 'धान'),
          ),
          const SizedBox(height: 10),
          TextField(
              controller: _party,
              decoration:
                  const InputDecoration(labelText: 'किसको बेचा (लोडर/मिल)')),
          const SizedBox(height: 10),
          TextField(
              controller: _bora,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'बोरी की संख्या')),
          const SizedBox(height: 10),
          TextField(
              controller: _weight,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'वज़न (क्विंटल)')),
          const SizedBox(height: 10),
          TextField(
              controller: _rate,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'भाव (₹ प्रति क्विंटल)')),
          const SizedBox(height: 10),
          TextField(
              controller: _vehicle,
              decoration: const InputDecoration(labelText: 'गाड़ी नंबर')),
          const SizedBox(height: 10),
          TextField(
              controller: _delivery,
              decoration: const InputDecoration(
                  labelText: 'डिलीवरी तारीख (2026-11-08)')),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: busy ? null : _save,
            child: Text(busy ? 'सेव हो रहा है…' : 'बिक्री सेव करें'),
          ),
          if (msg != null) ...[const SizedBox(height: 10), NoteBox(msg!)],
        ],
      ),
    );
  }
}

/// रसीद स्टेटस (admin)
class AdminReceiptStatusScreen extends StatefulWidget {
  const AdminReceiptStatusScreen({super.key});
  @override
  State<AdminReceiptStatusScreen> createState() => _AdminReceiptStatusScreenState();
}

class _AdminReceiptStatusScreenState extends State<AdminReceiptStatusScreen> {
  final _ref = TextEditingController();
  Map<String, dynamic>? data;
  String? error;

  Future<void> _find() async {
    try {
      final res = await Api.get(
          'public/receipt/status?ref=${Uri.encodeComponent(_ref.text.trim())}',
          auth: false);
      setState(() {
        data = res;
        error = null;
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  Future<void> _markPaid(String id) async {
    try {
      await Api.patch('receipts/$id/paid', {});
      _find();
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = data?['receipt'] as Map<String, dynamic>?;
    final paid = data?['paid'] == true;
    return Scaffold(
      appBar: AppBar(title: const Text('रसीद स्टेटस')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          const NoteBox('टोकन या रेफ़रेंस नंबर डालें।'),
          TextField(
              controller: _ref,
              decoration: const InputDecoration(hintText: 'टोकन / रेफ़रेंस नंबर')),
          const SizedBox(height: 10),
          FilledButton(onPressed: _find, child: const Text('🔎 देखें')),
          if (error != null) ...[const SizedBox(height: 10), NoteBox(error!)],
          if (r != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  children: [
                    InfoRow('स्थिति', data?['stage']?.toString() ?? '', bold: true),
                    InfoRow('किसान', r['kisanName']?.toString() ?? '—'),
                    InfoRow('मोबाइल', r['mobile']?.toString() ?? '—'),
                    InfoRow('अनाज', r['crop']?.toString() ?? '—'),
                    InfoRow('बोरी', '${r['bora'] ?? 0}'),
                    InfoRow('वज़न', '${r['weightQuintal'] ?? 0} क्विंटल'),
                    InfoRow('भुगतान',
                        '₹${r['payable'] ?? 0}${paid ? " (हो गया)" : " (बाकी)"}'),
                  ],
                ),
              ),
            ),
            if (!paid)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FilledButton.icon(
                  onPressed: () => _markPaid(r['receiptId'].toString()),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('✅ भुगतान हो गया'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// माल प्राप्ति रसीद — token
class PickupReceiptScreen extends StatefulWidget {
  const PickupReceiptScreen({super.key});
  @override
  State<PickupReceiptScreen> createState() => _PickupReceiptScreenState();
}

class _PickupReceiptScreenState extends State<PickupReceiptScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _mobile = TextEditingController();
  final _crop = TextEditingController();
  final _bora = TextEditingController();
  final _weight = TextEditingController();
  final _vehicle = TextEditingController();
  String? token;
  String? error;
  bool busy = false;

  Future<void> _save() async {
    setState(() {
      busy = true;
      error = null;
      token = null;
    });
    try {
      final res = await Api.post('receipts/pickup', {
        'kisanName': _name.text.trim(),
        'address': _address.text.trim(),
        'mobile': _mobile.text.trim(),
        'crop': _crop.text.trim(),
        'bora': double.tryParse(_bora.text) ?? 0,
        'weightQuintal': double.tryParse(_weight.text) ?? 0,
        'vehicleNo': _vehicle.text.trim(),
      });
      setState(() {
        token = (res['token'] ?? (res['receipt'] as Map?)?['token'])?.toString();
        busy = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('माल प्राप्ति रसीद')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          const NoteBox(
              'बोरी की संख्या के साथ दर्ज करें — सेव होते ही टोकन नंबर बनेगा।'),
          TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'किसान का नाम')),
          const SizedBox(height: 10),
          TextField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'पता / गाँव')),
          const SizedBox(height: 10),
          TextField(
              controller: _mobile,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'मोबाइल नंबर')),
          const SizedBox(height: 10),
          TextField(
              controller: _crop,
              decoration: const InputDecoration(labelText: 'अनाज का प्रकार')),
          const SizedBox(height: 10),
          TextField(
              controller: _bora,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'बोरी की संख्या')),
          const SizedBox(height: 10),
          TextField(
              controller: _weight,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'कुल वज़न (क्विंटल) — बिना तौले खाली छोड़ें')),
          const SizedBox(height: 10),
          TextField(
              controller: _vehicle,
              decoration: const InputDecoration(labelText: 'गाड़ी नंबर')),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: busy ? null : _save,
            child: Text(busy ? 'सेव हो रहा है…' : 'रसीद बनाएँ'),
          ),
          if (error != null) ...[const SizedBox(height: 10), NoteBox(error!)],
          if (token != null && token!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE2F5E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF96C8A5)),
              ),
              child: Column(
                children: [
                  const Text('✅ रसीद बन गई',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('टोकन नंबर', style: TextStyle(fontSize: 12)),
                  Text(token!,
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: RgtColors.green)),
                  const SizedBox(height: 6),
                  const Text(
                      'किसान को यही टोकन बताएं। माल गद्दी पर पहुँचने पर '
                      '"माल जमा रसीद" में यही टोकन डालें।',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// माल जमा रसीद
class FinalReceiptScreen extends StatefulWidget {
  const FinalReceiptScreen({super.key});
  @override
  State<FinalReceiptScreen> createState() => _FinalReceiptScreenState();
}

class _FinalReceiptScreenState extends State<FinalReceiptScreen> {
  final _token = TextEditingController();
  final _rate = TextEditingController();
  final _weight = TextEditingController();
  final _boraExp = TextEditingController();
  final _paldariExp = TextEditingController();
  final _zhariExp = TextEditingController();
  final _otherExp = TextEditingController();
  Map<String, dynamic>? receipt;
  Map<String, dynamic>? finalRec;
  String? error;

  double get _weightVal => double.tryParse(_weight.text) ?? 0;
  double get _rateVal => double.tryParse(_rate.text) ?? 0;
  double get _kharch =>
      (double.tryParse(_boraExp.text) ?? 0) +
      (double.tryParse(_paldariExp.text) ?? 0) +
      (double.tryParse(_zhariExp.text) ?? 0) +
      (double.tryParse(_otherExp.text) ?? 0);
  double get _gross => _weightVal * _rateVal;
  double get _payable => _gross - _kharch;

  Future<void> _find() async {
    try {
      final res = await Api.get('receipts/token/${_token.text.trim()}');
      final r = res['receipt'] as Map<String, dynamic>?;
      setState(() {
        receipt = r;
        error = r == null ? 'रिकॉर्ड नहीं मिला' : null;
        if (r != null) _weight.text = '${r['weightQuintal'] ?? 0}';
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  Future<void> _save() async {
    try {
      final res = await Api.post('receipts/final', {
        'receiptId': receipt?['receiptId'],
        'token': _token.text.trim(),
        'rate': _rateVal,
        'weightQuintal': _weightVal,
        'expenses': [
          if ((double.tryParse(_boraExp.text) ?? 0) > 0)
            {'label': 'बोरा', 'amount': double.parse(_boraExp.text)},
          if ((double.tryParse(_paldariExp.text) ?? 0) > 0)
            {'label': 'पलदारी', 'amount': double.parse(_paldariExp.text)},
          if ((double.tryParse(_zhariExp.text) ?? 0) > 0)
            {'label': 'झारी', 'amount': double.parse(_zhariExp.text)},
          if ((double.tryParse(_otherExp.text) ?? 0) > 0)
            {'label': 'अन्य', 'amount': double.parse(_otherExp.text)},
        ],
      });
      setState(() {
        finalRec = res['receipt'] as Map<String, dynamic>?;
        error = null;
      });
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('माल जमा रसीद')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          const NoteBox('टोकन नंबर डालें — किसान का पूरा रिकॉर्ड खुलेगा।'),
          TextField(
              controller: _token,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'टोकन नंबर')),
          const SizedBox(height: 10),
          FilledButton(onPressed: _find, child: const Text('रिकॉर्ड खोजें')),
          if (error != null) ...[const SizedBox(height: 10), NoteBox(error!)],
          if (receipt != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  children: [
                    InfoRow('किसान', receipt!['kisanName']?.toString() ?? '—'),
                    InfoRow('पता', receipt!['address']?.toString() ?? '—'),
                    InfoRow('अनाज', receipt!['crop']?.toString() ?? '—'),
                    InfoRow('बोरी', '${receipt!['bora'] ?? 0}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
                controller: _rate,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'अंतिम भाव (₹ प्रति क्विंटल)')),
            const SizedBox(height: 10),
            TextField(
                controller: _weight,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'कुल वज़न (क्विंटल)')),
            const SizedBox(height: 10),
            TextField(
                controller: _boraExp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'बोरा खर्च (₹)')),
            const SizedBox(height: 10),
            TextField(
                controller: _paldariExp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'पलदारी खर्च (₹)')),
            const SizedBox(height: 10),
            TextField(
                controller: _zhariExp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'झारी खर्च (₹) — तेलहान/दलहन')),
            const SizedBox(height: 10),
            TextField(
                controller: _otherExp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'अन्य खर्च (₹)')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F7EE),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: RgtColors.line),
              ),
              child: Column(
                children: [
                  InfoRow('कुल कीमत', '₹${_gross.toStringAsFixed(0)}'),
                  InfoRow('कुल खर्च', '₹${_kharch.toStringAsFixed(0)}'),
                  InfoRow('भुगतान होगा', '₹${_payable.toStringAsFixed(0)}',
                      bold: true),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _save, child: const Text('माल जमा रसीद बनाएँ')),
          ],
          if (finalRec != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE2F5E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF96C8A5)),
              ),
              child: Column(
                children: [
                  const Text('✅ माल जमा रसीद बन गई',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('रेफ़रेंस नंबर', style: TextStyle(fontSize: 12)),
                  Text(finalRec!['finalReceiptId']?.toString() ?? '',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: RgtColors.green)),
                  const SizedBox(height: 8),
                  InfoRow('कुल कीमत', '₹${finalRec!['gross'] ?? 0}'),
                  InfoRow('कुल खर्च', '₹${finalRec!['totalKharch'] ?? 0}'),
                  InfoRow('भुगतान', '₹${finalRec!['payable'] ?? 0}', bold: true),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// किसान सूची
class FarmersScreen extends StatefulWidget {
  const FarmersScreen({super.key});
  @override
  State<FarmersScreen> createState() => _FarmersScreenState();
}

class _FarmersScreenState extends State<FarmersScreen> {
  List<dynamic> farmers = [];
  String q = '';
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Api.get('farmers');
      setState(() => farmers = (res['farmers'] ?? []) as List<dynamic>);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = farmers.where((f) {
      if (q.isEmpty) return true;
      final m = f as Map<String, dynamic>;
      return '${m['name']} ${m['address']} ${m['mobile']}'
          .toLowerCase()
          .contains(q.toLowerCase());
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('किसान सूची')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                  hintText: 'नाम, पता या मोबाइल से खोजें',
                  prefixIcon: Icon(Icons.search)),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          if (error != null)
            Padding(padding: const EdgeInsets.all(12), child: NoteBox(error!)),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final m = filtered[i] as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 9),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['name']?.toString() ?? 'अज्ञात किसान',
                            style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: RgtColors.green)),
                        Text(
                            (m['address']?.toString().isNotEmpty ?? false)
                                ? m['address'].toString()
                                : 'पता दर्ज नहीं',
                            style: const TextStyle(
                                fontSize: 12.5, color: Color(0xFF464E46))),
                        const SizedBox(height: 3),
                        Text('📱 ${m['mobile'] ?? 'मोबाइल नहीं'}',
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: RgtColors.greenLight)),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          onPressed: () =>
                              dialNumber(m['mobile']?.toString() ?? ''),
                          icon: const Icon(Icons.call, size: 16),
                          label: const Text('कॉल',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// कॉल रिकॉर्डिंग
class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});
  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  List<dynamic> calls = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Api.get('calls?days=3');
      setState(() => calls = (res['calls'] ?? []) as List<dynamic>);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('कॉल रिकॉर्डिंग (3 दिन)')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          if (error != null) NoteBox(error!),
          if (calls.isEmpty) const NoteBox('अभी कोई कॉल नहीं'),
          ...calls.map((c) {
            final m = c as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${m['callerName'] ?? 'किसान'} · ${m['mobile'] ?? ''}',
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w700)),
                    if ((m['gist'] ?? '').toString().isNotEmpty)
                      Text(m['gist'].toString(),
                          style: const TextStyle(fontSize: 12.5)),
                    if ((m['transcript'] ?? '').toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(m['transcript'].toString(),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: RgtColors.grey)),
                      ),
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

/// About Us
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child:
                Image.asset('assets/images/about_godown.jpg', fit: BoxFit.fitWidth),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  InfoRow('कंपनी', AppConfig.about),
                  InfoRow('पता', AppConfig.address),
                  InfoRow('समय', 'सभी दिन — सुबह 8:00 से शाम 6:00'),
                  InfoRow('सपोर्ट', AppConfig.supportPhone),
                ],
              ),
            ),
          ),
          const SectionTitle('मालिक'),
          _owner('assets/images/owner_rajni.png', 'रजनी कांत', 'B.Tech, MBA'),
          _owner('assets/images/owner_ravi.png', 'रवि कांत', 'BTS, MBA'),
          const SizedBox(height: 10),
          const Center(
            child: Text(AppConfig.copyright,
                style: TextStyle(fontSize: 10, color: RgtColors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _owner(String img, String name, String edu) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Image.asset(img, width: 84, height: 84, fit: BoxFit.cover),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16,
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
