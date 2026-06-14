import 'dart:ui';
import 'package:flutter/material.dart';

/// Sinematik seyahat arka planı:
/// 1. Yüksek çözünürlüklü kamp/dağcılık görseli (NetworkImage – Unsplash)
/// 2. Okunabilirlik için karartma katmanı (ColorFilter – %55 siyah)
/// 3. Sinematik buğulanma (BackdropFilter – sigma 4)
/// 4. Çok hafif topografik çizgi overlay (CustomPainter – %6 opaklık)
class TravelBackground extends StatelessWidget {
  final Widget child;

  const TravelBackground({super.key, required this.child});

  // Gece kamp ateşi & çadır – Unsplash premium telifsiz görsel
  static const String _imageUrl =
      'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?q=80&w=1000';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Katman 1: Arka plan fotoğrafı + karartma filtresi ──────────────
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const NetworkImage(_imageUrl),
                fit: BoxFit.cover,
                // %55 siyah overlay → okunabilirlik sigortası
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.55),
                  BlendMode.srcOver,
                ),
                // Görsel yüklenene kadar gösterilecek koyu yedek
                onError: (_, __) {},
              ),
            ),
            // Görsel yüklenene kadar koyu gradient yedek
            foregroundDecoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000), // şeffaf üst
                  Color(0x33000000), // hafif koyu alt
                ],
              ),
            ),
          ),
        ),

        // ── Katman 2: Sinematik backdrop blur (derinlik efekti) ────────────
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),

        // ── Katman 3: Topografik seyahat çizgileri (çok hafif) ─────────────
        Positioned.fill(
          child: CustomPaint(
            painter: const TravelBackgroundPainter(),
          ),
        ),

        // ── Katman 4: Sayfa içeriği ─────────────────────────────────────────
        child,
      ],
    );
  }
}

/// Topoğrafik kontur çizgileri ve seyahat rotası painter'ı.
/// Tüm çizgiler %4–6 opaklıkta; form elemanlarına rakip olmaz.
class TravelBackgroundPainter extends CustomPainter {
  const TravelBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    final Paint dashedPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    // — Kontur Seti 1 (Üst bölge) —
    _drawCubic(canvas, linePaint, size,
        0, 0.12,   0.3, 0.04,  0.7, 0.22,  1.0, 0.14);
    _drawCubic(canvas, linePaint, size,
        0, 0.15,   0.3, 0.07,  0.7, 0.25,  1.0, 0.17);

    // — Kontur Seti 2 (Orta-Sağ bölge) —
    _drawCubic(canvas, linePaint, size,
        0.2, 0.45,  0.5, 0.55,  0.8, 0.35,  1.2, 0.42);
    _drawCubic(canvas, linePaint, size,
        0.17, 0.48, 0.47, 0.58, 0.77, 0.38, 1.2, 0.45);

    // — Kontur Seti 3 (Alt-Sol bölge) —
    _drawCubicAbs(canvas, linePaint, size,
        -50, 0.72,  0.25, 0.62, 0.55, 0.82, 0.95, 0.74);
    _drawCubicAbs(canvas, linePaint, size,
        -50, 0.75,  0.25, 0.65, 0.55, 0.85, 0.95, 0.77);

    // — Kesik seyahat rotası —
    final Path routePath = Path();
    routePath.moveTo(size.width * 0.1, size.height * 0.25);
    routePath.quadraticBezierTo(
      size.width * 0.4, size.height * 0.30,
      size.width * 0.85, size.height * 0.58,
    );
    _drawDashedPath(canvas, routePath, dashedPaint, 6.0, 4.0);
  }

  // Yüzdelik koordinatlarla kübik bezier çizer
  void _drawCubic(Canvas canvas, Paint paint, Size size,
      double x0, double y0,
      double cx1, double cy1,
      double cx2, double cy2,
      double x1, double y1) {
    final Path path = Path()
      ..moveTo(size.width * x0, size.height * y0)
      ..cubicTo(
        size.width * cx1, size.height * cy1,
        size.width * cx2, size.height * cy2,
        size.width * x1,  size.height * y1,
      );
    canvas.drawPath(path, paint);
  }

  // Başlangıç x değeri mutlak, diğerleri yüzdelik
  void _drawCubicAbs(Canvas canvas, Paint paint, Size size,
      double x0abs, double y0,
      double cx1, double cy1,
      double cx2, double cy2,
      double x1, double y1) {
    final Path path = Path()
      ..moveTo(x0abs, size.height * y0)
      ..cubicTo(
        size.width * cx1, size.height * cy1,
        size.width * cx2, size.height * cy2,
        size.width * x1,  size.height * y1,
      );
    canvas.drawPath(path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint,
      double dashWidth, double dashSpace) {
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
