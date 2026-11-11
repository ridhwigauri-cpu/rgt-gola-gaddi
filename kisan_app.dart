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

  /// Tab bar — footer ke UPAR, icon + label, active tab utha hua
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
      child: SizedBox(
        height: 62,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          itemCount: labels.length,
          itemBuilder: (context, i) {
            final on = i == tab;
            return GestureDetector(
              onTap: () => setState(() => tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 68,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: on
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [RgtColors.greenLight, RgtColors.green],
                        )
                      : null,
                  color: on ? null : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: on ? RgtColors.green : RgtColors.line,
                  ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[i],
                        size: 21,
                        color: on ? Colors.white : RgtColors.green),
                    const SizedBox(height: 2),
                    Text(
                      labels[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        height: 1.1,
                        fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                        color: on ? Colors.white : RgtColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
