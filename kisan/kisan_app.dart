import 'package:flutter/material.dart';
import '../core/speech.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'kisan_screens.dart';
import 'weather_screen.dart';

class KisanApp extends StatelessWidget {
  const KisanApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'RGT Gola Gaddi',
        theme: rgtTheme(),
        debugShowCheckedModeBanner: false,
        home: const KisanHome(),
      );
}

class KisanHome extends StatefulWidget {
  const KisanHome({super.key});
  @override
  State<KisanHome> createState() => _KisanHomeState();
}

class _KisanHomeState extends State<KisanHome> {
  int tab = 0; // भाव default khula

  static const labels = [
    'भाव', 'किसानी', 'रसीद', 'शुभ', 'पूछताछ', 'विज्ञापन', 'मौसम', 'सहायता',
  ];

  static const icons = <IconData>[
    Icons.currency_rupee,
    Icons.agriculture,
    Icons.receipt_long,
    Icons.call,
    Icons.forum_outlined,
    Icons.campaign_outlined,
    Icons.wb_sunny,
    Icons.support_agent,
  ];

  /// मौसम ka icon rangeen
  static const colors = <Color>[
    RgtColors.green,
    RgtColors.greenMid,
    RgtColors.blue,
    RgtColors.greenLight,
    RgtColors.purple,
    RgtColors.red,
    Color(0xFFFFA726), // मौसम — orange
    RgtColors.teal,
  ];

  @override
  void initState() {
    super.initState();
    // login/khulte hi audio message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Speech.say('अब आप आर जी टी के सर्वर से जुड़ गए हैं');
    });
  }

  Widget _body() {
    switch (tab) {
      case 0:
        return const RatesScreen();
      case 1:
        return const KisaaniScreen();
      case 2:
        return const ReceiptStatusScreen();
      case 3:
        return const ShubhScreen();
      case 4:
        return const EnquiryScreen();
      case 5:
        return const AdsScreen();
      case 6:
        return const WeatherScreen();
      default:
        return const HelpScreen();
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
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
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
              Icon(icons[i], size: 20, color: on ? Colors.white : c),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  labels[i],
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 9.5,
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
