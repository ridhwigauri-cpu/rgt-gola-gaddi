import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'admin_extra.dart';
import 'admin_screens.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'RGT Admin',
        theme: rgtTheme(),
        debugShowCheckedModeBanner: false,
        home: const AdminGate(),
      );
}

class AdminGate extends StatefulWidget {
  const AdminGate({super.key});
  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  bool loading = true;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      setState(() => loading = false);
      return;
    }
    Api.setToken(token);
    try {
      final me = await Api.me();
      setState(() {
        user = (me['user'] as Map<String, dynamic>?) ?? me;
        loading = false;
      });
    } catch (_) {
      Api.setToken(null);
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (user == null) {
      return LoginScreen(onDone: (u) => setState(() => user = u));
    }
    return AdminHome(
      user: user!,
      onLogout: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        Api.setToken(null);
        setState(() => user = null);
      },
    );
  }
}

/// Login — admin aur executive dono isi screen se (role server se aata hai)
class LoginScreen extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onDone;
  const LoginScreen({super.key, required this.onDone});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool busy = false;
  String? error;

  Future<void> _login() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final res = await Api.login(_email.text.trim(), _password.text);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', Api.token ?? '');
      widget.onDone((res['user'] as Map<String, dynamic>?) ?? res);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Image.asset('assets/images/login_truck.jpg',
                      height: 220, width: double.infinity, fit: BoxFit.cover),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.transparent,
                            RgtColors.cream,
                          ],
                          stops: const [0, 0.55, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 11,
                    child: Row(
                      children: [
                        Image.asset('assets/images/logo_round.png',
                            width: 34, height: 34),
                        const SizedBox(width: 9),
                        const Text('RGT Gola Gaddi',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  Shadow(blurRadius: 6, color: Colors.black54)
                                ])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('RGT Gola Gaddi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const Text('एडमिन और एग्ज़ीक्यूटिव लॉगिन\nतेलहाड़ा मंडी, नालंदा, बिहार',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: RgtColors.grey)),
            const SizedBox(height: 18),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'ईमेल'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'पासवर्ड'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: busy ? null : _login,
              child: Text(busy ? 'लॉगिन हो रहा है…' : 'लॉगिन करें'),
            ),
            if (error != null) ...[const SizedBox(height: 10), NoteBox(error!)],
            const SizedBox(height: 20),
            const RgtFooter(),
          ],
        ),
      ),
    );
  }
}

class AdminHome extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;
  const AdminHome({super.key, required this.user, required this.onLogout});
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int tab = 0;
  static const labels = ['डैशबोर्ड', 'किसानी', 'भाव', 'लीड्स', 'पूछताछ', 'और'];
  static const icons = [
    Icons.home_outlined, Icons.spa_outlined, Icons.currency_rupee,
    Icons.groups_outlined, Icons.chat_outlined, Icons.more_horiz,
  ];

  bool get isAdmin => (widget.user['role'] ?? '') == 'ADMIN';

  Widget _body() {
    switch (tab) {
      case 0:
        return AdminDashboard(user: widget.user);
      case 1:
        return const AdminKisaaniScreen();
      case 2:
        return const AdminRatesScreen();
      case 3:
        return const AdminLeadsScreen();
      case 4:
        return const AdminQueriesScreen();
      default:
        return const AdminMoreScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RgtHeader(
              onLogout: widget.onLogout,
              onLocationTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RgtMapScreen()),
              ),
            ),
            Expanded(child: _body()),
            const RgtFooter(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        height: 64,
        backgroundColor: Colors.white,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: List.generate(
          labels.length,
          (i) =>
              NavigationDestination(icon: Icon(icons[i], size: 22), label: labels[i]),
        ),
      ),
    );
  }
}
