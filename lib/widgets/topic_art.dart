import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/catalog.dart';
import 'fx.dart';

/// A glossy gradient tile holding the topic's icon.
class TopicBadge extends StatelessWidget {
  final Topic topic;
  final double size;
  const TopicBadge(this.topic, {super.key, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(size * 0.3);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: topic.gradient,
        borderRadius: r,
        boxShadow: [BoxShadow(color: topic.color.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Stack(
          children: [
            Positioned(
              right: -size * 0.25,
              top: -size * 0.3,
              child: Container(
                width: size * 0.75,
                height: size * 0.75,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
              ),
            ),
            Center(
              child: Icon(topic.icon, color: Colors.white, size: size * 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// A gradient header for a topic with drifting shapes and a large faded icon.
/// Each topic gets its own pattern so cards are recognisable at a glance.
class TopicBanner extends StatelessWidget {
  final Topic topic;
  final double height;
  final BorderRadius borderRadius;
  final Widget? child;

  const TopicBanner({
    super.key,
    required this.topic,
    required this.height,
    this.borderRadius = BorderRadius.zero,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: height,
        decoration: BoxDecoration(gradient: topic.gradient),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: AmbientBuilder(
                period: const Duration(seconds: 14),
                builder: (context, t, _) => CustomPaint(painter: _PatternPainter(topic.id, t)),
              ),
            ),
            Positioned(
              right: -height * 0.08,
              bottom: -height * 0.2,
              child: Icon(topic.icon, size: height * 1.05, color: Colors.white.withValues(alpha: 0.16)),
            ),
            ?child,
          ],
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final String seed;
  final double t;
  _PatternPainter(this.seed, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // A stable seed per topic (String.hashCode differs between platforms).
    final seedValue = seed.codeUnits.fold<int>(7, (a, c) => (a * 31 + c) & 0x7fffffff);
    final r = math.Random(seedValue);
    final p = t * 2 * math.pi;
    final w = size.width, h = size.height;

    // Big soft circles drifting.
    for (var i = 0; i < 3; i++) {
      final base = Offset(r.nextDouble() * w, r.nextDouble() * h);
      final radius = h * (0.35 + r.nextDouble() * 0.45);
      final drift = Offset(math.sin(p + i * 2) * h * 0.12, math.cos(p + i * 1.4) * h * 0.08);
      canvas.drawCircle(base + drift, radius, Paint()..color = Colors.white.withValues(alpha: 0.09));
    }

    // A dot grid tucked into one corner.
    final dots = Paint()..color = Colors.white.withValues(alpha: 0.28);
    final gx = w * (0.45 + r.nextDouble() * 0.2), gy = h * 0.16;
    final gap = math.max(9.0, h * 0.11);
    for (var x = 0; x < 5; x++) {
      for (var y = 0; y < 3; y++) {
        canvas.drawCircle(Offset(gx + x * gap, gy + y * gap), math.max(1.4, h * 0.018), dots);
      }
    }

    // A flowing squiggle.
    final wave = Path();
    final amp = h * 0.08, baseY = h * (0.62 + r.nextDouble() * 0.2);
    for (var x = 0.0; x <= w; x += 4) {
      final y = baseY + math.sin(x / (h * 0.28) + p) * amp;
      x == 0 ? wave.moveTo(x, y) : wave.lineTo(x, y);
    }
    canvas.drawPath(
      wave,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, h * 0.03)
        ..strokeCap = StrokeCap.round,
    );

    // A couple of twinkling sparkles and a ring.
    for (var i = 0; i < 2; i++) {
      final c = Offset(w * (0.2 + r.nextDouble() * 0.55), h * (0.2 + r.nextDouble() * 0.5));
      final k = 0.6 + 0.4 * math.sin(p * 3 + i * 2);
      final s = h * 0.07 * k;
      final star = Path()
        ..moveTo(c.dx, c.dy - s)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + s, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + s)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - s, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - s);
      canvas.drawPath(star, Paint()..color = Colors.white.withValues(alpha: 0.55));
    }
    canvas.drawCircle(
      Offset(w * (0.1 + r.nextDouble() * 0.3), h * (0.75 + math.sin(p) * 0.05)),
      h * 0.09,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, h * 0.025),
    );
  }

  @override
  bool shouldRepaint(_PatternPainter old) => old.t != t || old.seed != seed;
}
