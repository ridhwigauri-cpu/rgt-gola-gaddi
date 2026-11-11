import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';
import 'theme.dart';

/// Header — banner (bina kate) + 📍 location link + optional logout.
class RgtHeader extends StatelessWidget {
  final VoidCallback? onLocationTap;
  final VoidCallback? onLogout;
  const RgtHeader({super.key, this.onLocationTap, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
          child: Image.asset('assets/images/banner.jpg',
              width: double.infinity, fit: BoxFit.fitWidth),
        ),
        Positioned(
          right: 8,
          bottom: 6,
          child: GestureDetector(
            onTap: onLocationTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('📍 तेलहाड़ा मंडी · नालंदा, बिहार',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        if (onLogout != null)
          Positioned(
            right: 9,
            top: 8,
            child: TextButton(
              onPressed: onLogout,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                    side: const BorderSide(color: Colors.white54)),
              ),
              child: const Text('लॉगआउट', style: TextStyle(fontSize: 11.5)),
            ),
          ),
      ],
    );
  }
}

/// Footer — textured, uplifted, logo + copyright.
class RgtFooter extends StatelessWidget {
  const RgtFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF4F7EE), Color(0xFFE7ECDF)],
        ),
        border: const Border(top: BorderSide(color: Colors.white, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset('assets/images/logo_round.png', width: 34, height: 34),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RGT Gola Gaddi',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: RgtColors.green)),
                Text('A Unit of Ridhwi Gauri Traders Pvt Ltd',
                    style: TextStyle(fontSize: 9.5, color: Color(0xFF6E766E))),
                Text(AppConfig.copyright,
                    style: TextStyle(fontSize: 9, color: Color(0xFF969894))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// In-app map screen — landmark, road detail, photo, route.
class RgtMapScreen extends StatelessWidget {
  const RgtMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📍 RGT Gola Gaddi — तेलहाड़ा मंडी')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/hero_gaddi.jpg', fit: BoxFit.cover),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.black.withOpacity(0.45),
                    child: Text(
                      '📍 ${AppConfig.lat}, ${AppConfig.lng}  ·  Plus Code 65GH+HFG',
                      style: const TextStyle(color: Colors.white, fontSize: 11.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    '🏬 लैंडमार्क: मोज़फ़राबाद (Mozafrabad), तेलहाड़ा-नालंदा रोड — प्लस कोड 65GH+HFG',
                    style: TextStyle(fontSize: 11.5)),
                const SizedBox(height: 4),
                const Text(
                    '🛣 सड़क: मुख्य सड़क से ट्रक सीधे गद्दी तक · तुलाई कांटा गद्दी परिसर में',
                    style: TextStyle(fontSize: 11.5, color: RgtColors.grey)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: openRoute,
                        icon: const Icon(Icons.navigation, size: 18),
                        label: const Text('🧭 रास्ता'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: openGoogleMaps,
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('🗺 Google Map'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> openRoute() async {
  final nav = Uri.parse('google.navigation:q=${AppConfig.lat},${AppConfig.lng}');
  if (await canLaunchUrl(nav)) {
    await launchUrl(nav);
    return;
  }
  final dir = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${AppConfig.lat},${AppConfig.lng}&travelmode=driving');
  if (await canLaunchUrl(dir)) {
    await launchUrl(dir, mode: LaunchMode.externalApplication);
    return;
  }
  await launchUrl(Uri.parse('geo:${AppConfig.lat},${AppConfig.lng}'));
}

Future<void> openGoogleMaps() async {
  final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${AppConfig.lat},${AppConfig.lng}');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> dialNumber(String number) async {
  final clean = number.replaceAll(RegExp(r'[^0-9+]'), '');
  if (clean.isEmpty) return;
  await launchUrl(Uri.parse('tel:$clean'));
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const InfoRow(this.label, this.value, {super.key, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 104,
              child: Text(label,
                  style: const TextStyle(fontSize: 12.5, color: RgtColors.grey))),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: RgtColors.green)),
      );
}

class NoteBox extends StatelessWidget {
  final String text;
  const NoteBox(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F7EE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: RgtColors.line),
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF4A5348))),
      );
}
