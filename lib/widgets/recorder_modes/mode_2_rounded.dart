import 'dart:math';
import 'package:flutter/material.dart';
import 'package:voice_levels_app/l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════
//  Mode 2 — Rounded View (Kids Playful)
// ═══════════════════════════════════════════════════════════

class Mode2RoundedView extends StatefulWidget {
  final double normalized;
  final Color accent;
  final int maxLevel;

  const Mode2RoundedView({super.key, required this.normalized, required this.accent, this.maxLevel = 10});

  @override
  State<Mode2RoundedView> createState() => _Mode2RoundedViewState();
}

class _Mode2RoundedViewState extends State<Mode2RoundedView>
    with TickerProviderStateMixin {
  late final AnimationController _ripple1;
  late final AnimationController _ripple2;
  late final AnimationController _ripple3;
  late final AnimationController _rotateCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _bounceCtrl;
  double _prevNorm = 0;

  @override
  void initState() {
    super.initState();
    _ripple1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    _ripple2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    _ripple3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    Future.delayed(const Duration(milliseconds: 600), () { if (mounted) _ripple2.forward(from: 0.33); });
    Future.delayed(const Duration(milliseconds: 1200), () { if (mounted) _ripple3.forward(from: 0.66); });

    _rotateCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();
    _pulseCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))..repeat(reverse: true);
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  }

  @override
  void didUpdateWidget(covariant Mode2RoundedView old) {
    super.didUpdateWidget(old);
    if (widget.normalized > 0.65 && widget.normalized > _prevNorm + 0.12) {
      _bounceCtrl.forward(from: 0).then((_) => _bounceCtrl.reverse());
    }
    _prevNorm = widget.normalized;
  }

  @override
  void dispose() {
    _ripple1.dispose(); _ripple2.dispose(); _ripple3.dispose();
    _rotateCtrl.dispose(); _pulseCtrl.dispose(); _bounceCtrl.dispose();
    super.dispose();
  }

  Color _zoneColor(double n) {
    if (n < 0.40) return const Color(0xFF6BCB77);
    if (n < 0.65) return const Color(0xFFFFD93D);
    if (n < 0.85) return const Color(0xFFFF9F1C);
    return const Color(0xFFFF6B6B);
  }

  String _emoji(double n) {
    if (n < 0.25) return '😴';
    if (n < 0.50) return '😊';
    if (n < 0.75) return '😄';
    return '🤩';
  }

  String _label(BuildContext context, double n) {
  final t = AppLocalizations.of(context)!;

  if (n < 0.25) return t.labelQuiet2;
  if (n < 0.50) return t.labelLouder2;
  if (n < 0.75) return t.labelLoud2;
  return t.labelAmazing2;
}

  @override
  Widget build(BuildContext context) {
    final n     = widget.normalized.clamp(0.0, 1.0);
    final color = _zoneColor(n);
    final cSize = 130.0 + n * 90.0;
    final t = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(_label(context, n), key: ValueKey(_label(context, n)),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color,
              shadows: [Shadow(color: color.withOpacity(0.35), offset: const Offset(0, 2), blurRadius: 8)])),
        ),

        const SizedBox(height: 24),

        // Main circle stage
        SizedBox(
          width: 290, height: 290,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripples
              if (n > 0.10) ...[
                _RippleRing(ctrl: _ripple1, color: color, maxRadius: 140, opacity: 0.20),
                _RippleRing(ctrl: _ripple2, color: color, maxRadius: 140, opacity: 0.14),
                _RippleRing(ctrl: _ripple3, color: color, maxRadius: 140, opacity: 0.09),
              ],

              // Rotating dashed orbit
              AnimatedBuilder(
                animation: _rotateCtrl,
                builder: (_, __) => Transform.rotate(
                  angle: _rotateCtrl.value * 2 * pi,
                  child: CustomPaint(
                    size: Size(cSize + 40, cSize + 40),
                    painter: _DashedRingPainter(color: color.withOpacity(0.45)),
                  ),
                ),
              ),

              // Outer soft ring
              AnimatedContainer(
                duration: const Duration(milliseconds: 200), curve: Curves.easeOut,
                width: cSize + 24, height: cSize + 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.12),
                  border: Border.all(color: color.withOpacity(0.28), width: 2),
                ),
              ),

              // Middle ring
              AnimatedContainer(
                duration: const Duration(milliseconds: 180), curve: Curves.easeOut,
                width: cSize + 10, height: cSize + 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.18)),
              ),

              // Main glowing circle
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) {
                  final glowR = n > 0.6 ? 24.0 + _pulseCtrl.value * 20 : 14.0;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180), curve: Curves.easeOutBack,
                    width: cSize, height: cSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.35),
                        colors: [Color.lerp(color, Colors.white, 0.38)!, color, color.withOpacity(0.78)],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.55), blurRadius: glowR, spreadRadius: 4),
                        BoxShadow(color: color, blurRadius: 0, offset: const Offset(0, 7)),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Inner rotating arcs
                    AnimatedBuilder(
                      animation: _rotateCtrl,
                      builder: (_, __) => Transform.rotate(
                        angle: -_rotateCtrl.value * 2 * pi * 0.6,
                        child: CustomPaint(
                          size: Size(cSize * 0.7, cSize * 0.7),
                          painter: _InnerArcPainter(color: Colors.white.withOpacity(0.18)),
                        ),
                      ),
                    ),
                    // Shine highlight
                    Align(
                      alignment: const Alignment(-0.4, -0.55),
                      child: Container(
                        width: cSize * 0.26, height: cSize * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    // Bouncing mascot
                    AnimatedBuilder(
                      animation: _bounceCtrl,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, -sin(_bounceCtrl.value * pi) * 16), child: child!),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                        child: Text(_emoji(n), key: ValueKey(_emoji(n)),
                            style: TextStyle(fontSize: cSize * 0.28)),
                      ),
                    ),
                  ],
                ),
              ),

              // Orbiting stars when loud
              if (n > 0.55)
                AnimatedBuilder(
                  animation: _rotateCtrl,
                  builder: (_, __) => CustomPaint(
                    size: Size(cSize + 54, cSize + 54),
                    painter: _OrbitStarsPainter(
                      progress: _rotateCtrl.value,
                      color: color,
                      count: n > 0.80 ? 6 : 4,
                      orbitRadius: cSize / 2 + 24,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Percentage pill
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) => Transform.scale(
            scale: n > 0.8 ? 1.0 + _pulseCtrl.value * 0.08 : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 11),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: color, blurRadius: 0, offset: const Offset(0, 5)),
                  BoxShadow(color: color.withOpacity(0.30), blurRadius: 16, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${(n * widget.maxLevel).round()}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28,
                      shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)]),
                  ),
                  Text(
                    ' / ${widget.maxLevel}',
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Zone dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ZoneDot(label: t.zoneDotQuietPlayful, color: const Color(0xFF6BCB77), active: n >= 0.05),
            const SizedBox(width: 8),
            _ZoneDot(label: t.zoneGood,  color: const Color(0xFFFFD93D), active: n >= 0.40),
            const SizedBox(width: 8),
            _ZoneDot(label: t.zoneLoud,  color: const Color(0xFFFF9F1C), active: n >= 0.65),
            const SizedBox(width: 8),
            _ZoneDot(label: t.zoneMax,   color: const Color(0xFFFF6B6B), active: n >= 0.85),
          ],
        ),
      ],
    );
  }
}

// ── Ripple Ring ───────────────────────────────────────────
class _RippleRing extends StatelessWidget {
  final AnimationController ctrl;
  final Color color;
  final double maxRadius;
  final double opacity;
  const _RippleRing({required this.ctrl, required this.color, required this.maxRadius, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final r = ctrl.value * maxRadius;
        final o = (1.0 - ctrl.value) * opacity;
        return Container(
          width: r * 2, height: r * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(o), width: 2.5),
          ),
        );
      },
    );
  }
}

// ── Dashed ring painter ───────────────────────────────────
class _DashedRingPainter extends CustomPainter {
  final Color color;
  const _DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2;
    final cx = size.width / 2; final cy = size.height / 2;
    final r  = size.width / 2 - 2;
    const dashCount = 20;
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i / dashCount) * 2 * pi;
      final sweepAngle = (0.7 / dashCount) * 2 * pi;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter old) => old.color != color;
}

// ── Inner arc decorator ───────────────────────────────────
class _InnerArcPainter extends CustomPainter {
  final Color color;
  const _InnerArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    final cx = size.width / 2; final cy = size.height / 2; final r = size.width / 2;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.75), 0.3, 1.5, false, paint);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.50), 3.0, 1.2, false, paint);
  }

  @override
  bool shouldRepaint(covariant _InnerArcPainter old) => old.color != color;
}

// ── Orbit stars painter ───────────────────────────────────
class _OrbitStarsPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int count;
  final double orbitRadius;
  const _OrbitStarsPainter({required this.progress, required this.color, required this.count, required this.orbitRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2; final cy = size.height / 2;
    final paint = Paint()..color = color.withOpacity(0.90);
    for (int i = 0; i < count; i++) {
      final angle = (progress * 2 * pi) + (i * 2 * pi / count);
      final x = cx + orbitRadius * cos(angle);
      final y = cy + orbitRadius * sin(angle);
      _drawStar(canvas, Offset(x, y), i % 2 == 0 ? 6.0 : 4.0, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    const pts = 4;
    for (int i = 0; i < pts * 2; i++) {
      final radius = i.isEven ? r : r * 0.45;
      final angle  = (i * pi / pts) - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitStarsPainter old) => old.progress != progress;
}

// ── Zone dot ──────────────────────────────────────────────
class _ZoneDot extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  const _ZoneDot({required this.label, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.18) : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? color.withOpacity(0.55) : Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: active ? color : Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
            boxShadow: active ? [BoxShadow(color: color, blurRadius: 6)] : [],
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
            color: active ? color : Colors.white.withOpacity(0.35))),
      ]),
    );
  }
}