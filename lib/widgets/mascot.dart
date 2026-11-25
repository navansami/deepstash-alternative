import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'fx.dart';

/// Kip, the app's mascot: a little kernel with a sprout on its head.
/// Drawn entirely in code so it scales crisply and can change expression.
enum MascotMood { happy, wave, cheer, wow, thinking, reading, sleepy, sad }

const kipOrange = Color(0xFFFF8A3D);

class Mascot extends StatefulWidget {
  final double size;
  final MascotMood mood;
  final Color color;

  const Mascot({super.key, this.size = 96, this.mood = MascotMood.happy, this.color = kipOrange});

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
  late final AnimationController _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 90));
  late final AnimationController _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  final _rng = math.Random();
  Timer? _blinkTimer;
  bool _running = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final on = Motion.of(context);
    if (on && !_running) {
      _running = true;
      _idle.repeat();
      _scheduleBlink();
    } else if (!on && _running) {
      _running = false;
      _idle.stop();
      _blinkTimer?.cancel();
    }
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(Duration(milliseconds: 1600 + _rng.nextInt(3200)), () async {
      if (!mounted || !_running) return;
      await _blink.forward(from: 0);
      if (!mounted) return;
      await _blink.reverse();
      if (mounted && _running) _scheduleBlink();
    });
  }

  @override
  void didUpdateWidget(Mascot old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood && _running) _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _idle.dispose();
    _blink.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _KipPainter(_idle, _blink, _pop, widget.mood, widget.color),
        ),
      ),
    );
  }
}

class _KipPainter extends CustomPainter {
  final Animation<double> idle, blink, pop;
  final MascotMood mood;
  final Color color;

  _KipPainter(this.idle, this.blink, this.pop, this.mood, this.color)
    : super(repaint: Listenable.merge([idle, blink, pop]));

  static const _ink = Color(0xFF3A2218);
  static const _leaf = Color(0xFF4CB963);
  static const _leafDark = Color(0xFF2F9A4A);
  static const _blush = Color(0xFFFF6B8A);
  static const _gold = Color(0xFFFFC53D);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final ph = idle.value * 2 * math.pi;
    final squash = math.sin(pop.value * math.pi) * (1 - pop.value);

    final bob = switch (mood) {
      MascotMood.cheer => -math.sin(ph * 2).abs() * 0.07 * s,
      MascotMood.sleepy => math.sin(ph) * 0.008 * s,
      _ => math.sin(ph) * 0.022 * s,
    };

    final w = s * 0.62, h = s * 0.64;
    final light = Color.lerp(color, Colors.white, 0.5)!;
    final dark = Color.lerp(color, Colors.black, 0.22)!;

    // Ground shadow shrinks as Kip rises.
    final shadowScale = (1 + bob / (s * 0.22)).clamp(0.5, 1.2);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(s / 2, s * 0.94), width: s * 0.46 * shadowScale, height: s * 0.06 * shadowScale),
      Paint()..color = Colors.black.withValues(alpha: 0.13),
    );

    canvas.save();
    canvas.translate(s / 2, s * 0.6 + bob);
    canvas.scale(1 + 0.1 * squash, 1 - 0.1 * squash);
    if (mood == MascotMood.sleepy) canvas.rotate(0.08 + math.sin(ph) * 0.03);
    if (mood == MascotMood.thinking) canvas.rotate(-0.07);

    final armPaint = Paint()
      ..color = dark
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Arms that sit behind the body.
    _armsBehind(canvas, s, w, h, ph, armPaint);

    // Sprout.
    canvas.save();
    canvas.translate(0, -h / 2 + s * 0.015);
    final sway = switch (mood) {
      MascotMood.cheer => math.sin(ph * 2) * 0.28,
      MascotMood.sleepy => 0.45 + math.sin(ph) * 0.04,
      MascotMood.sad => 0.3,
      _ => math.sin(ph) * 0.12,
    };
    canvas.rotate(sway);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(s * 0.025, -s * 0.05, 0, -s * 0.1),
      Paint()
        ..color = _leafDark
        ..strokeWidth = s * 0.028
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    final leafL = Path()
      ..moveTo(0, -s * 0.095)
      ..quadraticBezierTo(-s * 0.05, -s * 0.2, -s * 0.15, -s * 0.15)
      ..quadraticBezierTo(-s * 0.08, -s * 0.07, 0, -s * 0.095);
    final leafR = Path()
      ..moveTo(0, -s * 0.095)
      ..quadraticBezierTo(s * 0.05, -s * 0.22, s * 0.16, -s * 0.2)
      ..quadraticBezierTo(s * 0.1, -s * 0.09, 0, -s * 0.095);
    canvas.drawPath(leafL, Paint()..color = _leaf);
    canvas.drawPath(leafR, Paint()..color = _leaf);
    canvas.drawPath(
      Path()
        ..moveTo(s * 0.01, -s * 0.1)
        ..quadraticBezierTo(s * 0.07, -s * 0.15, s * 0.13, -s * 0.18),
      Paint()
        ..color = _leafDark.withValues(alpha: 0.5)
        ..strokeWidth = s * 0.01
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();

    // Body: an egg-shaped kernel.
    final body = Path()
      ..moveTo(0, -h / 2)
      ..cubicTo(w * 0.42, -h / 2, w / 2, -h * 0.05, w / 2, h * 0.12)
      ..cubicTo(w / 2, h * 0.38, w * 0.28, h / 2, 0, h / 2)
      ..cubicTo(-w * 0.28, h / 2, -w / 2, h * 0.38, -w / 2, h * 0.12)
      ..cubicTo(-w / 2, -h * 0.05, -w * 0.42, -h / 2, 0, -h / 2)
      ..close();
    final bodyRect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, color, dark],
          stops: const [0, 0.5, 1],
        ).createShader(bodyRect),
    );
    // Belly and shine.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, h * 0.24), width: w * 0.56, height: h * 0.36),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-w * 0.22, -h * 0.27), width: w * 0.16, height: h * 0.1),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );

    // Face.
    final er = s * 0.055;
    final ey = -h * 0.04;
    for (final side in [-1.0, 1.0]) {
      _eye(canvas, Offset(side * w * 0.19, ey), er, side, ph);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(side * w * 0.33, h * 0.1), width: er * 1.9, height: er * 1.1),
        Paint()..color = _blush.withValues(alpha: 0.45),
      );
    }
    _mouth(canvas, h * 0.12, er, ph);

    // Arms and props in front of the body.
    _armsFront(canvas, s, w, h, ph, armPaint);
    canvas.restore();

    _extras(canvas, s, ph, bob);
  }

  void _eye(Canvas canvas, Offset c, double er, double side, double ph) {
    final stroke = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = er * 0.5
      ..strokeCap = StrokeCap.round;
    switch (mood) {
      case MascotMood.cheer:
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - er, c.dy + er * 0.35)
            ..quadraticBezierTo(c.dx, c.dy - er * 1.3, c.dx + er, c.dy + er * 0.35),
          stroke,
        );
        return;
      case MascotMood.sleepy:
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - er, c.dy)
            ..quadraticBezierTo(c.dx, c.dy + er * 0.9, c.dx + er, c.dy),
          stroke,
        );
        return;
      default:
    }
    final big = mood == MascotMood.wow ? 1.25 : 1.0;
    final look = switch (mood) {
      MascotMood.thinking => Offset(er * 0.3, -er * 0.35),
      MascotMood.reading => Offset(0, er * 0.35),
      _ => Offset.zero,
    };
    final rx = er * 0.82 * big;
    final ry = er * 1.08 * big * (1 - blink.value * 0.88);
    final center = c + look;
    canvas.drawOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2), Paint()..color = _ink);
    if (blink.value < 0.5) {
      final white = Paint()..color = Colors.white;
      canvas.drawCircle(center + Offset(-rx * 0.3, -ry * 0.38), rx * 0.38, white);
      canvas.drawCircle(center + Offset(rx * 0.32, ry * 0.36), rx * 0.16, white);
    }
    if (mood == MascotMood.sad || mood == MascotMood.thinking) {
      // Brows: sad ones tilt up toward the middle; a thinking brow lifts on one side.
      final inner = -side;
      final raise = mood == MascotMood.sad ? er * 0.6 : (side > 0 ? er * 0.5 : 0.0);
      canvas.drawLine(
        Offset(c.dx - inner * er, c.dy - er * 1.7 - (mood == MascotMood.thinking ? raise : 0)),
        Offset(c.dx + inner * er * 0.9, c.dy - er * 1.7 - raise),
        stroke..strokeWidth = er * 0.38,
      );
    }
  }

  void _mouth(Canvas canvas, double my, double er, double ph) {
    final mw = er * 0.95;
    final ink = Paint()..color = _ink;
    final stroke = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = er * 0.42
      ..strokeCap = StrokeCap.round;
    switch (mood) {
      case MascotMood.cheer:
        final m = Path()
          ..moveTo(-mw * 1.2, my - er * 0.15)
          ..quadraticBezierTo(0, my + mw * 2.6, mw * 1.2, my - er * 0.15)
          ..close();
        canvas.drawPath(m, ink);
        canvas.save();
        canvas.clipPath(m);
        canvas.drawCircle(Offset(0, my + mw * 1.35), mw * 0.7, Paint()..color = const Color(0xFFFF7A8A));
        canvas.restore();
      case MascotMood.wow:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, my + er * 0.4),
            width: er * 0.95,
            height: er * 1.25 * (1 + 0.12 * math.sin(ph * 2)),
          ),
          ink,
        );
      case MascotMood.thinking:
        canvas.drawPath(
          Path()
            ..moveTo(-mw * 0.3, my + er * 0.35)
            ..quadraticBezierTo(mw * 0.3, my + er * 0.05, mw * 0.8, my + er * 0.25),
          stroke,
        );
      case MascotMood.sleepy:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(0, my + er * 0.3),
            width: er * 0.55,
            height: er * 0.55 * (1 + 0.35 * math.sin(ph)),
          ),
          ink,
        );
      case MascotMood.sad:
        canvas.drawPath(
          Path()
            ..moveTo(-mw * 0.8, my + er * 0.6)
            ..quadraticBezierTo(0, my - er * 0.2, mw * 0.8, my + er * 0.6),
          stroke,
        );
      default:
        canvas.drawPath(
          Path()
            ..moveTo(-mw, my)
            ..quadraticBezierTo(0, my + mw * 1.15, mw, my),
          stroke,
        );
    }
  }

  // Angle 0 points right, positive angles point down.
  void _arm(Canvas canvas, Offset from, double angle, double len, double side, Paint p) {
    final end = from + Offset(side * math.cos(angle), math.sin(angle)) * len;
    canvas.drawLine(from, end, p);
  }

  void _armsBehind(Canvas canvas, double s, double w, double h, double ph, Paint p) {
    final len = s * 0.14;
    final left = Offset(-w * 0.45, h * 0.1), right = Offset(w * 0.45, h * 0.1);
    switch (mood) {
      case MascotMood.cheer:
        final a = -1.0 + math.sin(ph * 4) * 0.25;
        _arm(canvas, left, a, len, -1, p);
        _arm(canvas, right, a, len, 1, p);
      case MascotMood.wave:
        _arm(canvas, left, 1.05 + math.sin(ph) * 0.06, len, -1, p);
        _arm(canvas, right, -1.15 + math.sin(ph * 4) * 0.45, len, 1, p);
      case MascotMood.wow:
        _arm(canvas, left, -0.4, len, -1, p);
        _arm(canvas, right, -0.4, len, 1, p);
      case MascotMood.reading || MascotMood.thinking:
        if (mood == MascotMood.thinking) _arm(canvas, left, 1.05, len, -1, p);
      default:
        _arm(canvas, left, 1.05 + math.sin(ph) * 0.07, len, -1, p);
        _arm(canvas, right, 1.05 - math.sin(ph) * 0.07, len, 1, p);
    }
  }

  void _armsFront(Canvas canvas, double s, double w, double h, double ph, Paint p) {
    if (mood == MascotMood.thinking) {
      // A hand on the chin.
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.45, h * 0.12)
          ..quadraticBezierTo(w * 0.42, h * 0.36, w * 0.14, h * 0.27),
        p,
      );
      canvas.drawCircle(Offset(w * 0.14, h * 0.27), s * 0.045, Paint()..color = p.color);
      return;
    }
    if (mood != MascotMood.reading) return;
    // An open book held in both hands, pages turning gently.
    final bookTop = h * 0.16;
    final bw = w * 0.4, bh = h * 0.28;
    final tilt = math.sin(ph) * 0.03;
    canvas.save();
    canvas.translate(0, bookTop + bh / 2);
    canvas.rotate(tilt);
    final cover = Paint()..color = const Color(0xFF3867D6);
    final page = Paint()..color = const Color(0xFFFFFBF2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: bw * 2 + s * 0.03, height: bh + s * 0.03),
        Radius.circular(s * 0.02),
      ),
      cover,
    );
    canvas.drawRect(Rect.fromLTWH(-bw, -bh / 2, bw - s * 0.004, bh), page);
    canvas.drawRect(Rect.fromLTWH(s * 0.004, -bh / 2, bw, bh), page);
    final lines = Paint()
      ..color = const Color(0xFFB8B2A6)
      ..strokeWidth = s * 0.008;
    for (var i = 0; i < 3; i++) {
      final y = -bh / 2 + bh * (0.28 + i * 0.22);
      canvas.drawLine(Offset(-bw * 0.82, y), Offset(-bw * 0.18, y), lines);
      canvas.drawLine(Offset(bw * 0.18, y), Offset(bw * 0.82, y), lines);
    }
    canvas.restore();
    final hand = Paint()..color = p.color;
    canvas.drawLine(Offset(-w * 0.45, h * 0.1), Offset(-bw * 0.95, bookTop + bh * 0.55), p);
    canvas.drawLine(Offset(w * 0.45, h * 0.1), Offset(bw * 0.95, bookTop + bh * 0.55), p);
    canvas.drawCircle(Offset(-bw * 0.95, bookTop + bh * 0.55), s * 0.035, hand);
    canvas.drawCircle(Offset(bw * 0.95, bookTop + bh * 0.55), s * 0.035, hand);
  }

  void _extras(Canvas canvas, double s, double ph, double bob) {
    if (mood == MascotMood.cheer || mood == MascotMood.wow) {
      const spots = [Offset(0.12, 0.3), Offset(0.88, 0.22), Offset(0.9, 0.62), Offset(0.08, 0.68)];
      for (var i = 0; i < spots.length; i++) {
        final k = 0.55 + 0.45 * math.sin(ph * 2 + i * 1.7);
        _sparkle(canvas, Offset(spots[i].dx * s, spots[i].dy * s), s * 0.055 * k, i.isEven ? _gold : Colors.white);
      }
    }
    if (mood == MascotMood.sleepy) {
      final stroke = Paint()
        ..color = const Color(0xFF7C8DB5)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      for (var i = 0; i < 3; i++) {
        final p = (idle.value + i / 3) % 1;
        final z = s * 0.055 * (0.6 + p * 0.6);
        final o = Offset(s * (0.7 + p * 0.12), s * (0.3 - p * 0.24));
        stroke
          ..strokeWidth = s * 0.016
          ..color = const Color(0xFF7C8DB5).withValues(alpha: 1 - p);
        canvas.drawPath(
          Path()
            ..moveTo(o.dx, o.dy)
            ..lineTo(o.dx + z, o.dy)
            ..lineTo(o.dx, o.dy + z)
            ..lineTo(o.dx + z, o.dy + z),
          stroke,
        );
      }
    }
    if (mood == MascotMood.thinking) {
      // Thought bubbles rising to the side.
      final p = Paint()..color = Colors.white.withValues(alpha: 0.9);
      final outline = Paint()
        ..color = const Color(0xFFB8B2A6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.008;
      for (var i = 0; i < 3; i++) {
        final r = s * (0.018 + i * 0.014) * (1 + 0.1 * math.sin(ph + i));
        final c = Offset(s * (0.78 + i * 0.05), s * (0.32 - i * 0.09) + bob * 0.5);
        canvas.drawCircle(c, r, p);
        canvas.drawCircle(c, r, outline);
      }
    }
  }

  void _sparkle(Canvas canvas, Offset c, double r, Color color) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_KipPainter old) => old.mood != mood || old.color != color;
}

/// A speech bubble whose tail points left, toward the speaker.
class SpeechBubble extends StatelessWidget {
  final String text;
  const SpeechBubble(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = scheme.surfaceContainerHighest;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(size: const Size(10, 18), painter: _TailPainter(bg)),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: scheme.onSurface, height: 1.3),
            ),
          ),
        ),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  final Color color;
  _TailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width + 1, 0)
        ..quadraticBezierTo(size.width * 0.4, size.height * 0.55, 0, size.height * 0.75)
        ..quadraticBezierTo(size.width * 0.6, size.height * 0.85, size.width + 1, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) => old.color != color;
}

/// Kip with a speech bubble. The bubble pops when the message changes.
class MascotSays extends StatelessWidget {
  final String message;
  final MascotMood mood;
  final double size;

  const MascotSays({super.key, required this.message, this.mood = MascotMood.happy, this.size = 84});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Mascot(size: size, mood: mood),
        const SizedBox(width: 6),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, a) => ScaleTransition(
                scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                alignment: Alignment.centerLeft,
                child: FadeTransition(opacity: a, child: child),
              ),
              child: SpeechBubble(message, key: ValueKey(message)),
            ),
          ),
        ),
      ],
    );
  }
}
