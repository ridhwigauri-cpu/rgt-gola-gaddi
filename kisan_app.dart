import 'package:flutter/material.dart';
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

  // har label ke hisaab se icon
  static const icons = <IconData>[
    Icons.currency_rupee,        // भाव — rate
    Icons.agriculture,           // किसानी — kheti
    Icons.receipt_long,          // रसीद — receipt
    Icons.call,                  // शुभ — call
    Icons.forum_outlined,        // पूछताछ — baat-cheet
    Icons.campaign_outlined,     // विज्ञापन — ad
    Icons.wb_sunny_outlined,     // मौसम — weather
    Icons.support_agent,         // सहायता — help
  ];

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

  /// Tab bar — footer ke UPAR, do row me (4 + 4), bade icon
  Widget _tabItem(int i) {
    final on = i == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tab = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            gradient: on
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [RgtColors.greenLight, RgtColors.green],
                  )
                : null,
            color: on ? null : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: on ? RgtColors.green : RgtColors.line),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: RgtColors.green.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icons[i],
                  size: 24, color: on ? Colors.white : RgtColors.green),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  labels[i],
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.1,
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
      padding: const EdgeInsets.fromLTRB(5, 6, 5, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [for (var i = 0; i < 4; i++) _tabItem(i)]),
          const SizedBox(height: 6),
          Row(children: [for (var i = 4; i < labels.length; i++) _tabItem(i)]),
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
            _tabBar(),          // tabs footer ke upar
            const RgtFooter(),
          ],
        ),
      ),
    );
  }
}
