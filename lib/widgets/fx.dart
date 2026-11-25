import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'mascot.dart';

/// Global switch for looping "ambient" motion (idle mascot, drifting shapes).
/// Tests turn it off so `pumpAndSettle` can settle; users who ask the OS to
/// reduce motion get the same calm version.
class Motion {
  static bool ambient = true;

  static bool of(BuildContext context) => ambient && !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
}

/// Rebuilds [builder] with a looping phase `t` in [0, 1). Holds still (t = 0) when motion is off.
class AmbientBuilder extends StatefulWidget {
  final Duration period;
  final Widget Function(BuildContext context, double t, Widget? child) builder;
  final Widget? child;

  const AmbientBuilder({super.key, required this.period, required this.builder, this.child});

  @override
  State<AmbientBuilder> createState() => _AmbientBuilderState();
}

class _AmbientBuilderState extends State<AmbientBuilder> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.of(context)) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, child) => widget.builder(context, _c.value, child),
    child: widget.child,
  );
}

/// Fades and slides its child in once, after an optional [delay] (for staggered lists).
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset offset;

  const FadeSlideIn({super.key, required this.child, this.delay = Duration.zero, this.offset = const Offset(0, 0.12)});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  static const _length = Duration(milliseconds: 460);
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.delay + _length);
  late final Animation<double> _a = CurvedAnimation(
    parent: _c,
    curve: Interval(
      widget.delay.inMilliseconds / (widget.delay + _length).inMilliseconds,
      1,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void initState() {
    super.initState();
    if (Motion.ambient) {
      _c.forward();
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: SlideTransition(
      position: Tween(begin: widget.offset, end: Offset.zero).animate(_a),
      child: widget.child,
    ),
  );
}

/// A rounded progress bar with a gradient fill that springs to its new value.
class GradientProgressBar extends StatelessWidget {
  final double value;
  final List<Color> colors;
  final double height;

  const GradientProgressBar({super.key, required this.value, required this.colors, this.height = 10});

  @override
  Widget build(BuildContext context) {
    final track = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Semantics(
      value: '${(value * 100).round()}%',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        builder: (context, v, _) => Container(
          height: height,
          decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(height)),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(height),
                boxShadow: [
                  BoxShadow(color: colors.last.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              // A soft highlight along the top edge makes the bar look glossy.
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: height * 0.35,
                  margin: EdgeInsets.symmetric(horizontal: height * 0.5, vertical: height * 0.12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(height),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const flameColors = [Color(0xFFFFD43B), Color(0xFFFF8A3D), Color(0xFFE5484D)];

/// The streak flame: flickers with a warm gradient when the daily goal is met.
class StreakFlame extends StatelessWidget {
  final bool lit;
  final double size;
  const StreakFlame({super.key, required this.lit, this.size = 26});

  @override
  Widget build(BuildContext context) {
    final icon = Icon(Icons.local_fire_department_rounded, size: size, color: Colors.white);
    if (!lit) {
      return Icon(
        Icons.local_fire_department_rounded,
        size: size,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
      );
    }
    return AmbientBuilder(
      period: const Duration(milliseconds: 1100),
      child: ShaderMask(
        shaderCallback: (r) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: flameColors,
        ).createShader(r),
        child: icon,
      ),
      builder: (context, t, child) {
        final p = t * 2 * math.pi;
        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.diagonal3Values(1 + 0.05 * math.sin(p * 2), 1 + 0.09 * math.sin(p), 1)
            ..rotateZ(0.06 * math.sin(p * 3)),
          child: child,
        );
      },
    );
  }
}

/// An icon button that pops and throws a ring of sparks when it becomes active (e.g. like).
class PopIconButton extends StatefulWidget {
  final bool active;
  final IconData icon;
  final IconData activeIcon;
  final Color activeColor;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const PopIconButton({
    super.key,
    required this.active,
    required this.icon,
    required this.activeIcon,
    required this.activeColor,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<PopIconButton> createState() => _PopIconButtonState();
}

class _PopIconButtonState extends State<PopIconButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  static final _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.5).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.88), weight: 25),
    TweenSequenceItem(
      tween: Tween<double>(begin: 0.88, end: 1).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 45,
    ),
  ]);

  @override
  void didUpdateWidget(PopIconButton old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active && Motion.of(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: widget.tooltip,
      onPressed: widget.onPressed,
      icon: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _SparkRing(_c.value, widget.activeColor),
          child: Transform.scale(
            scale: _c.isAnimating ? _scale.transform(_c.value) : 1,
            child: Icon(
              widget.active ? widget.activeIcon : widget.icon,
              color: widget.active ? widget.activeColor : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _SparkRing extends CustomPainter {
  final double t;
  final Color color;
  _SparkRing(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0 || t == 1) return;
    final c = size.center(Offset.zero);
    final fade = (1 - t).clamp(0.0, 1.0);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * fade
      ..color = color.withValues(alpha: 0.5 * fade);
    canvas.drawCircle(c, 6 + 16 * Curves.easeOut.transform(t), ring);
    const n = 8;
    for (var i = 0; i < n; i++) {
      final a = i / n * 2 * math.pi + 0.3;
      final r = 10 + 18 * Curves.easeOutCubic.transform(t);
      final dotColor = i.isEven ? color : const Color(0xFFFFB547);
      canvas.drawCircle(
        c + Offset(math.cos(a), math.sin(a)) * r,
        2.6 * fade,
        Paint()..color = dotColor.withValues(alpha: fade),
      );
    }
  }

  @override
  bool shouldRepaint(_SparkRing old) => old.t != t || old.color != color;
}

/// Soft colored blobs drifting slowly behind [child].
class BlobBackground extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  const BlobBackground({super.key, required this.colors, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AmbientBuilder(
              period: const Duration(seconds: 20),
              builder: (context, t, _) => CustomPaint(painter: _BlobPainter(t, colors)),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double t;
  final List<Color> colors;
  _BlobPainter(this.t, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final p = t * 2 * math.pi;
    for (var i = 0; i < colors.length; i++) {
      final phase = i * 2.1;
      final center = Offset(
        size.width * (0.5 + 0.38 * math.cos(p + phase)),
        size.height * (0.45 + 0.32 * math.sin(p + phase * 1.3)),
      );
      final radius = size.shortestSide * (0.55 + 0.08 * math.sin(p * 2 + phase));
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(colors: [colors[i].withValues(alpha: 0.32), colors[i].withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.t != t;
}

/// Three dots that bounce in turn, for "working on it" states.
class BouncingDots extends StatelessWidget {
  final Color? color;
  const BouncingDots({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return AmbientBuilder(
      period: const Duration(milliseconds: 1100),
      builder: (context, t, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Transform.translate(
              offset: Offset(0, -7 * math.max(0, math.sin((t - i * 0.15) * 2 * math.pi))),
              child: Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.5 + 0.17 * i),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Throws a burst of confetti over the whole screen. Does nothing when motion is reduced.
void showConfetti(BuildContext context) {
  if (!Motion.of(context)) return;
  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => IgnorePointer(child: _Confetti(onDone: () => entry.remove())),
  );
  overlay.insert(entry);
}

/// Confetti plus a little dialog where the mascot cheers.
Future<void> celebrate(
  BuildContext context, {
  required String title,
  required String message,
  String action = 'Keep going',
}) {
  showConfetti(context);
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Mascot(size: 140, mood: MascotMood.cheer),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () => Navigator.pop(ctx),
                child: Text(action, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _Particle {
  final double x0, vx, vy, spin, phase, size;
  final Color color;
  final int shape; // 0 rect, 1 circle, 2 ribbon
  _Particle(this.x0, this.vx, this.vy, this.spin, this.phase, this.size, this.color, this.shape);
}

class _Confetti extends StatefulWidget {
  final VoidCallback onDone;
  const _Confetti({required this.onDone});

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti> with SingleTickerProviderStateMixin {
  static const _seconds = 2.8;
  static const _palette = [
    Color(0xFFFF8A3D),
    Color(0xFFFFD43B),
    Color(0xFF51CF66),
    Color(0xFF339AF0),
    Color(0xFFCC5DE8),
    Color(0xFFFF6B8A),
    Color(0xFF22B8CF),
  ];
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (_seconds * 1000).round()),
  );
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    _particles = [
      for (var i = 0; i < 140; i++)
        // Two cannons, bottom-left and bottom-right, firing up and inwards.
        _Particle(
          i.isEven ? -0.02 : 1.02,
          (i.isEven ? 1 : -1) * (0.25 + r.nextDouble() * 0.55),
          -(1.25 + r.nextDouble() * 0.75),
          (r.nextDouble() - 0.5) * 14,
          r.nextDouble() * 6,
          6 + r.nextDouble() * 7,
          _palette[r.nextInt(_palette.length)],
          r.nextInt(3),
        ),
    ];
    _c.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(painter: _ConfettiPainter(_c.value * _seconds, _particles)),
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  final List<_Particle> particles;
  _ConfettiPainter(this.t, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    const g = 1.35;
    final fade = t > _ConfettiState._seconds * 0.7
        ? 1 - (t - _ConfettiState._seconds * 0.7) / (_ConfettiState._seconds * 0.3)
        : 1.0;
    for (final p in particles) {
      final drift = (1 - math.exp(-1.4 * t)) / 1.4; // horizontal drag
      final x = (p.x0 + p.vx * drift) * size.width + math.sin(t * 5 + p.phase) * 8;
      final y = (1.02 + p.vy * t + 0.5 * g * t * t) * size.height;
      final paint = Paint()..color = p.color.withValues(alpha: fade.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * t + p.phase);
      switch (p.shape) {
        case 0:
          // Flip along one axis to fake a 3D tumble.
          canvas.scale(1, math.cos(t * 9 + p.phase));
          canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), paint);
        case 1:
          canvas.drawCircle(Offset.zero, p.size * 0.38, paint);
        default:
          final path = Path()
            ..moveTo(-p.size, 0)
            ..quadraticBezierTo(-p.size / 2, -p.size * 0.6, 0, 0)
            ..quadraticBezierTo(p.size / 2, p.size * 0.6, p.size, 0);
          canvas.drawPath(
            path,
            paint
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.6
              ..strokeCap = StrokeCap.round,
          );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
