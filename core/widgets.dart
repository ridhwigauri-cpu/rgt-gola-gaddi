import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';
import 'theme.dart';

/// 3D texture — halki diagonal lines + gloss (depth ke liye)
class _TexPainter extends CustomPainter {
  final bool dark;
  const _TexPainter({this.dark = false});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..strokeWidth = 1;
    final step = 7.0;
    for (double x = -size.height; x < size.width + size.height; x += step) {
      p.color = dark ? const Color(0x14FFFFFF) : const Color(0x0D1E2A1C);
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
    for (double x = -size.height; x < size.width + size.height; x += step * 2) {
      p.color = dark ? const Color(0x0A000000) : const Color(0x07FFFFFF);
      canvas.drawLine(Offset(x + size.height, size.height), Offset(x, 0), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Header — 3D banner + 📍 location link + optional logout
class RgtHeader extends StatelessWidget {
  final VoidCallback? onLocationTap;
  final VoidCallback? onLogout;
  const RgtHeader({super.key, this.onLocationTap, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.55),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
        child: Stack(
          children: [
            // banner photo
            Image.asset('assets/images/banner.jpg',
                width: double.infinity, fit: BoxFit.fitWidth),

            // 3D depth — neeche gehra gradient + upar gloss
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.18),
                      Colors.transparent,
                      Colors.black.withOpacity(0.10),
                      Colors.black.withOpacity(0.42),
                    ],
                    stops: const [0, 0.28, 0.72, 1],
                  ),
                ),
              ),
            ),

            // texture
            Positioned.fill(child: CustomPaint(painter: const _TexPainter())),

            // rim light — upar patli chamak
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1.4,
                color: Colors.white.withOpacity(0.65),
              ),
            ),

            // 📍 location
            Positioned(
              right: 8,
              bottom: 7,
              child: GestureDetector(
                onTap: onLocationTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.black.withOpacity(0.60),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.35), width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text('📍 तेलहाड़ा मंडी · नालंदा, बिहार',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black54)
                          ])),
                ),
              ),
            ),

            if (onLogout != null)
              Positioned(
                right: 9,
                top: 9,
                child: GestureDetector(
                  onTap: onLogout,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.38),
                          Colors.white.withOpacity(0.14),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.55), width: 0.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.30),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text('लॉगआउट',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black54)
                            ])),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Footer — 3D textured bar (uplifted), logo + copyright
class RgtFooter extends StatelessWidget {
  const RgtFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Stack(
          children: [
            // base gradient — upar safed, neeche cream/gehra
            Container(
              padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF6F8F1),
                    Color(0xFFE4EADB),
                  ],
                  stops: [0, 0.55, 1],
                ),
              ),
              child: Row(
                children: [
                  // logo 3D badge
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/logo_round.png',
                        width: 36, height: 36),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RGT Gola Gaddi',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: RgtColors.green,
                                shadows: [
                                  Shadow(
                                      color: Colors.white,
                                      blurRadius: 1,
                                      offset: Offset(0, 1))
                                ])),
                        Text('A Unit of Ridhwi Gauri Traders Pvt Ltd',
                            style: TextStyle(
                                fontSize: 9.5, color: Color(0xFF5C665C))),
                        Text(AppConfig.copyright,
                            style: TextStyle(
                                fontSize: 9, color: Color(0xFF8E968C))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // texture + gloss
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: const _TexPainter()),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1.4,
                color: Colors.white.withOpacity(0.95),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1.2,
                color: const Color(0xFFC9D2C2),
              ),
            ),
          ],
        ),
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
