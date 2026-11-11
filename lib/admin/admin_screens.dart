import 'package:flutter/material.dart';
import '../core/api.dart';
import '../core/config.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../kisan/kisan_screens.dart' show KisaaniScreen;
import 'admin_extra.dart';

/// Executive chunne ka dialog
Future<Map<String, dynamic>?> loadExecutives(BuildContext context) async {
  List<dynamic> users = [];
  try {
    final res = await Api.get('users/executives');
    users = (res['users'] ?? []) as List<dynamic>;
  } catch (_) {}
  if (users.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('कोई कर्मचारी नहीं — पहले एग्ज़ीक्यूटिव बनाएँ')));
    }
    return null;
  }
  if (!context.mounted) return null;
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (_) => SimpleDialog(
      title: const Text('कर्मचारी चुनें'),
      children: users.map((u) {
        final m = u as Map<String, dynamic>;
        return SimpleDialogOption(
          onPressed: () => Navigator.pop(context, m),
          child: Text('${m['name'] ?? m['email']}  (${m['role'] ?? 'EXECUTIVE'})'),
        );
      }).toList(),
    ),
  );
}

/// डैशबोर्ड
class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> user;
  const AdminDashboard({super.key, required this.user});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? stats;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Api.get('dashboard/summary');
      setState(() => stats = res);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset('assets/images/hero_directors.jpg',
                fit: BoxFit.fitWidth),
          ),
          const SizedBox(height: 10),
          SectionTitle('नमस्ते, ${widget.user['name'] ?? 'RGT'}'),
          if (error != null) NoteBox(error!),
          if (stats != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  children: [
                    InfoRow('आज की लीड्स', '${stats!['todayLeads'] ?? 0}'),
                    InfoRow('कुल किसान', '${stats!['farmers'] ?? 0}'),
                    InfoRow('पूछताछ बाकी', '${stats!['openQueries'] ?? 0}'),
                    InfoRow('आज की कॉल', '${stats!['todayCalls'] ?? 0}'),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('गद्दी',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: RgtColors.green)),
                  SizedBox(height: 6),
                  InfoRow('पता', 'तेलहाड़ा मंडी, नालंदा, बिहार'),
                  InfoRow('समय', 'सभी दिन — सुबह 8:00 से शाम 6:00'),
                  InfoRow('सपोर्ट', '06111-291499'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminKisaaniScreen extends StatelessWidget {
  const AdminKisaaniScreen({super.key});
  @override
  Widget build(BuildContext context) => const KisaaniScreen();
}

/// भाव — admin edit
class AdminRatesScreen extends StatefulWidget {
  const AdminRatesScreen({super.key});
  @override
  State<AdminRatesScreen> createState() => _AdminRatesScreenState();
}

class _AdminRatesScreenState extends State<AdminRatesScreen> {
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
      final res = await Api.get('rates');
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

  Future<void> _edit(Map<String, dynamic> r) async {
    final min = TextEditingController(text: '${r['minRate'] ?? r['rate'] ?? ''}');
    final max = TextEditingController(text: '${r['maxRate'] ?? ''}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${r['cropNameHindi'] ?? r['cropId']} — भाव'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: min,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'कम से कम (₹/क्विंटल)')),
            const SizedBox(height: 8),
            TextField(
                controller: max,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'ज़्यादा से ज़्यादा (₹/क्विंटल)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('रद्द')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('सेव')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Api.post('rates', {
        'cropId': r['cropId'],
        'minRate': double.tryParse(min.text) ?? 0,
        'maxRate': double.tryParse(max.text) ?? 0,
      });
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
    if (loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        const SectionTitle('आज का भाव'),
        if (error != null) NoteBox(error!),
        ...rates.map((r) {
          final m = r as Map<String, dynamic>;
          final min = m['minRate'] ?? m['rate'] ?? 0;
          final max = m['maxRate'] ?? 0;
          return Card(
            margin: const EdgeInsets.only(bottom: 9),
            child: ListTile(
              leading: const Icon(Icons.grass, color: RgtColors.greenLight),
              title: Text(m['cropNameHindi']?.toString() ?? '${m['cropId']}'),
              subtitle: Text('₹$min – ₹$max / क्विंटल'),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: () => _edit(m),
            ),
          );
        }),
      ],
    );
  }
}

/// लीड्स — assign
class AdminLeadsScreen extends StatefulWidget {
  const AdminLeadsScreen({super.key});
  @override
  State<AdminLeadsScreen> createState() => _AdminLeadsScreenState();
}

class _AdminLeadsScreenState extends State<AdminLeadsScreen> {
  List<dynamic> leads = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Api.get('leads');
      setState(() {
        leads = (res['leads'] ?? []) as List<dynamic>;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _assign(String leadId) async {
    final exec = await loadExecutives(context);
    if (exec == null) return;
    try {
      await Api.post('leads/$leadId/assign-to', {'assignedTo': exec['userId']});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${exec['name']} को दे दिया')));
      }
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
    if (loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          const SectionTitle('लीड्स (शुभ की कॉल से)'),
          if (error != null) NoteBox(error!),
          if (leads.isEmpty) const NoteBox('अभी कोई लीड नहीं'),
          ...leads.map((l) {
            final m = l as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                              '${m['callerName'] ?? 'किसान'} · ${m['cropNameHindi'] ?? ''}',
                              style: const TextStyle(
                                  fontSize: 14.5, fontWeight: FontWeight.w700)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF4EA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(m['status']?.toString() ?? '',
                              style: const TextStyle(fontSize: 10.5)),
                        ),
                      ],
                    ),
                    if ((m['mobile'] ?? '').toString().isNotEmpty)
                      Text('📱 ${m['mobile']}',
                          style: const TextStyle(
                              fontSize: 12.5, color: RgtColors.green)),
                    if ((m['assignedToName'] ?? '').toString().isNotEmpty)
                      Text('अभी: ${m['assignedToName']}',
                          style: const TextStyle(
                              fontSize: 12, color: RgtColors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _assign(m['leadId'].toString()),
                          icon: const Icon(Icons.person_add_alt, size: 16),
                          label: const Text('एग्ज़ीक्यूटिव को दें',
                              style: TextStyle(fontSize: 12)),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              dialNumber(m['mobile']?.toString() ?? ''),
                          icon: const Icon(Icons.call, size: 16),
                          label: const Text('कॉल', style: TextStyle(fontSize: 12)),
                        ),
                      ],
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

/// पूछताछ — assign
class AdminQueriesScreen extends StatefulWidget {
  const AdminQueriesScreen({super.key});
  @override
  State<AdminQueriesScreen> createState() => _AdminQueriesScreenState();
}

class _AdminQueriesScreenState extends State<AdminQueriesScreen> {
  List<dynamic> queries = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Api.get('queries');
      setState(() {
        queries = (res['queries'] ?? []) as List<dynamic>;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _assign(String id) async {
    final exec = await loadExecutives(context);
    if (exec == null) return;
    try {
      await Api.post('queries/$id/assign-to', {'assignedTo': exec['userId']});
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
    if (loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        const SectionTitle('पूछताछ (किसान ऐप से)'),
        if (error != null) NoteBox(error!),
        if (queries.isEmpty) const NoteBox('अभी कोई पूछताछ नहीं'),
        ...queries.map((q) {
          final m = q as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.only(bottom: 9),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${m['name'] ?? 'किसान'} · ${m['mobile'] ?? ''}',
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w700)),
                  if ((m['village'] ?? '').toString().isNotEmpty)
                    Text('${m['village']}',
                        style: const TextStyle(
                            fontSize: 12.5, color: RgtColors.grey)),
                  if ((m['question'] ?? m['crop'] ?? '').toString().isNotEmpty)
                    Text('${m['question'] ?? m['crop']}',
                        style: const TextStyle(fontSize: 12.5)),
                  if ((m['assignedToName'] ?? '').toString().isNotEmpty)
                    Text('अभी: ${m['assignedToName']}',
                        style: const TextStyle(
                            fontSize: 12, color: RgtColors.grey)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _assign(m['queryId'].toString()),
                    icon: const Icon(Icons.person_add_alt, size: 16),
                    label: const Text('कर्मचारी चुनें',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// और
class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_MoreItem>[
      _MoreItem('📦', 'स्टॉक', 'फसल के हिसाब से बोरी, वज़न, भुगतान',
          () => _push(context, const StockScreen())),
      _MoreItem('🚚', 'बिक्री (स्टॉक से)', 'लोडर/मिल को माल — स्टॉक घटेगा',
          () => _push(context, const SaleScreen())),
      _MoreItem('🔎', 'रसीद स्टेटस', 'टोकन या रेफ़रेंस से माल की स्थिति',
          () => _push(context, const AdminReceiptStatusScreen())),
      _MoreItem('🧾', 'माल प्राप्ति रसीद', 'टोकन बनेगा — किसान को बताएं',
          () => _push(context, const PickupReceiptScreen())),
      _MoreItem('💰', 'माल जमा रसीद', 'वज़न, बोरी, भाव, खर्च — भुगतान तय',
          () => _push(context, const FinalReceiptScreen())),
      _MoreItem('🧑‍🌾', 'किसान सूची', 'नाम, पता, मोबाइल',
          () => _push(context, const FarmersScreen())),
      _MoreItem('📞', 'कॉल रिकॉर्डिंग', 'शुभ की कॉल और जिस्ट',
          () => _push(context, const CallsScreen())),
      _MoreItem('ℹ️', 'About Us', 'RGT Gola Gaddi — पूरी जानकारी',
          () => _push(context, const AboutScreen())),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        const SectionTitle('और'),
        ...items.map((it) => Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: ListTile(
                leading: Text(it.emoji, style: const TextStyle(fontSize: 22)),
                title: Text(it.title,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700)),
                subtitle: Text(it.sub, style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: it.onTap,
              ),
            )),
        const SizedBox(height: 10),
        const Center(
          child: Text(AppConfig.copyright,
              style: TextStyle(fontSize: 10, color: RgtColors.grey)),
        ),
      ],
    );
  }

  static void _push(BuildContext c, Widget w) =>
      Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));
}

class _MoreItem {
  final String emoji;
  final String title;
  final String sub;
  final VoidCallback onTap;
  _MoreItem(this.emoji, this.title, this.sub, this.onTap);
}
