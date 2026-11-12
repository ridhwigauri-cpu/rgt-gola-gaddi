import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api.dart';
import '../core/speech.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import '../kisan/weather_screen.dart';
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
      return LoginScreen(
        onDone: (u) {
          setState(() => user = u);
          Speech.say('आर जी टी ग्रुप में आपका स्वागत है');
        },
      );
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

/// Login — admin aur executive dono isi screen se
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

  static const labels = [
    'डैशबोर्ड', 'किसानी', 'भाव', 'लीड्स', 'पूछताछ', 'मौसम', 'और',
  ];

  static const icons = <IconData>[
    Icons.dashboard_outlined,
    Icons.agriculture,
    Icons.currency_rupee,
    Icons.groups_outlined,
    Icons.forum_outlined,
    Icons.wb_sunny,
    Icons.more_horiz,
  ];

  static const colors = <Color>[
    RgtColors.green,
    RgtColors.greenMid,
    RgtColors.goldDark,
    RgtColors.blue,
    RgtColors.purple,
    Color(0xFFFFA726), // मौसम — rangeen
    RgtColors.teal,
  ];

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
      case 5:
        return const WeatherScreen();
      default:
        return const AdminMoreScreen();
    }
  }

  Widget _tabItem(int i) {
    final on = i == tab;
    final c = colors[i];
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tab = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            gradient: on
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [c.withOpacity(0.85), RgtColors.green],
                  )
                : null,
            color: on ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: on ? RgtColors.green : RgtColors.line),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: RgtColors.green.withOpacity(0.30),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icons[i], size: 22, color: on ? Colors.white : c),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  labels[i],
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.05,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w600,
                    color: on ? Colors.white : RgtColors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(int from, int to) => Row(
        children: [
          for (var i = from; i < to; i++)
            i < labels.length ? _tabItem(i) : const Spacer(),
        ],
      );

  /// 3 row me tabs — footer ke upar
  Widget _tabBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFCFDFA), Color(0xFFEEF2E9)],
        ),
        border: const Border(top: BorderSide(color: Colors.white, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row(0, 3),
          _row(3, 6),
          _row(6, 9),
        ],
      ),
    );
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
            _tabBar(),
            const RgtFooter(),
          ],
        ),
      ),
    );
  }
}
