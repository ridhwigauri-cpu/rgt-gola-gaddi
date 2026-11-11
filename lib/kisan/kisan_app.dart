import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'kisan_screens.dart';

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
  int tab = 0; // bhav default khula

  static const labels = ['भाव', 'किसानी', 'रसीद', 'शुभ', 'पूछताछ', 'विज्ञापन', 'सहायता'];
  static const icons = [
    Icons.currency_rupee, Icons.spa, Icons.receipt_long, Icons.call,
    Icons.chat_bubble_outline, Icons.campaign_outlined, Icons.headset_mic_outlined,
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
      default:
        return const HelpScreen();
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
        indicatorColor: RgtColors.greenLight.withOpacity(0.18),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: List.generate(
          labels.length,
          (i) => NavigationDestination(
            icon: Icon(icons[i], size: 22),
            label: labels[i],
          ),
        ),
      ),
    );
  }
}
