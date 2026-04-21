import 'dart:math';
import 'package:flutter/material.dart';
import 'package:voice_levels_app/l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════
//  Mode 4 — Playful View (Kids Playful)
// ═══════════════════════════════════════════════════════════

class Mode4PlayfulView extends StatefulWidget {
  final double normalized;
  final Color accent;
  final int maxLevel;

  const Mode4PlayfulView({super.key, required this.normalized, required this.accent, this.maxLevel = 10});

  @override
  State<Mode4PlayfulView> createState() => _Mode4PlayfulViewState();
}

class _Mode4PlayfulViewState extends State<Mode4PlayfulView>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _confettiCtrl;
  late final AnimationController _wobbleCtrl;
  late final AnimationController _shakeCtrl;

  // Confetti particles
  late List<_ConfettiParticle> _particles;
  final _rng = Random();
  double _prevNorm = 0;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))
      ..repeat(reverse: true);
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _wobbleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _particles = List.generate(16, (_) => _ConfettiParticle(_rng));
  }

  @override
  void didUpdateWidget(covariant Mode4PlayfulView old) {
    super.didUpdateWidget(old);
    // Trigger wobble on level spike
    if (widget.normalized > 0.55 && widget.normalized > _prevNorm + 0.10) {
      _wobbleCtrl.forward(from: 0).then((_) => _wobbleCtrl.reverse());
    }
    // Trigger shake when MAX
    if (widget.normalized > 0.88 && _prevNorm <= 0.88) {
      _shakeCtrl.forward(from: 0).then((_) => _shakeCtrl.reverse());
      // Regenerate confetti
      setState(() => _particles = List.generate(18, (_) => _ConfettiParticle(_rng)));
    }
    _prevNorm = widget.normalized;
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _confettiCtrl.dispose();
    _wobbleCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Color _zoneColor(double n) {
    if (n < 0.40) return const Color(0xFF6BCB77);
    if (n < 0.65) return const Color(0xFFFFD93D);
    if (n < 0.85) return const Color(0xFFFF9F1C);
    return const Color(0xFFFF6B6B);
  }

  String _emoji(double n) {
    if (n < 0.20) return '🐢';
    if (n < 0.40) return '🐣';
    if (n < 0.60) return '🐥';
    if (n < 0.80) return '🚀';
    return '🌟';
  }

  String _reaction(BuildContext context, double n) {
    final l = AppLocalizations.of(context)!;
    if (n < 0.20) return l.labelQuiet4;
    if (n < 0.40) return l.labelLouder4;
    if (n < 0.60) return l.labelGetting4;
    if (n < 0.80) return l.labelKeep4;
    return l.labelIncredible4;
  }

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context)!;
    final n     = widget.normalized.clamp(0.0, 1.0);
    final color = _zoneColor(n);

    // Star/balloon rises & grows with level
    final riseOffset = -(n * 100.0);           // moves up 0..100px
    final charScale  = 0.70 + n * 0.65;        // grows 0.7..1.35
    final charSize   = 80.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        // ── Reaction label ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(_reaction(context, n), key: ValueKey(_reaction(context, n)),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color,
              shadows: [Shadow(color: color.withOpacity(0.40), offset: const Offset(0, 2), blurRadius: 8)])),
        ),

        const SizedBox(height: 16),

        // ── Main stage ──
        SizedBox(
          width: double.infinity,
          height: 260,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [

              // Ground shadow
              Positioned(
                bottom: 8,
                child: AnimatedBuilder(
                  animation: _floatCtrl,
                  builder: (_, __) {
                    final scaleX = 0.4 + n * 0.6 - sin(_floatCtrl.value * pi) * 0.08;
                    return Transform.scale(
                      scaleX: scaleX, scaleY: 1.0,
                      child: Container(
                        width: 100, height: 14,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Confetti (only when loud)
              if (n > 0.65)
                ...List.generate(_particles.length, (i) {
                  final p = _particles[i];
                  return AnimatedBuilder(
                    animation: _confettiCtrl,
                    builder: (_, __) {
                      final t = (_confettiCtrl.value + p.offset) % 1.0;
                      final x = p.startX + sin(t * pi * 2 + p.phase) * 30;
                      final y = 260 - t * 280;
                      final opacity = (1.0 - t).clamp(0.0, 1.0);
                      return Positioned(
                        left: x,
                        bottom: y,
                        child: Opacity(
                          opacity: opacity,
                          child: Transform.rotate(
                            angle: t * pi * 4 * p.spin,
                            child: Container(
                              width: p.size, height: p.size,
                              decoration: BoxDecoration(
                                color: p.color,
                                borderRadius: p.isCircle
                                    ? BorderRadius.circular(p.size)
                                    : BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),

              // Glow rings behind character when loud
              if (n > 0.50)
                Positioned(
                  bottom: 30 + (-riseOffset * 0.5),
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) {
                      final glowSize = (charSize * charScale) + 20 + _pulseCtrl.value * 24;
                      return Container(
                        width: glowSize, height: glowSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.08 + _pulseCtrl.value * 0.07),
                        ),
                      );
                    },
                  ),
                ),

              // Main character: rises, grows, wobbles, shakes
              AnimatedBuilder(
                animation: Listenable.merge([_floatCtrl, _wobbleCtrl, _shakeCtrl]),
                builder: (_, __) {
                  final floatDy = sin(_floatCtrl.value * pi) * 10;
                  final wobble  = sin(_wobbleCtrl.value * pi * 3) * 14;
                  final shake   = sin(_shakeCtrl.value * pi * 8) * 8;

                  return Positioned(
                    bottom: 30.0 + (-riseOffset) + floatDy,
                    child: Transform.rotate(
                      angle: (wobble + shake) * pi / 180,
                      child: AnimatedScale(
                        scale: charScale,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, child) {
                            // Glow shadow on the emoji container
                            final glowOpacity = n > 0.7 ? 0.3 + _pulseCtrl.value * 0.25 : 0.0;
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(glowOpacity),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                            child: Text(
                              _emoji(n),
                              key: ValueKey(_emoji(n)),
                              style: TextStyle(fontSize: charSize),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Sparkle stars orbiting when very loud
              if (n > 0.70)
                AnimatedBuilder(
                  animation: _floatCtrl,
                  builder: (_, __) {
                    final orbitCenterBottom = 30.0 + (-riseOffset);
                    return Positioned(
                      bottom: orbitCenterBottom - 45,
                      child: CustomPaint(
                        size: const Size(140, 140),
                        painter: _OrbitStarsPainter(
                          progress: _floatCtrl.value,
                          color: color,
                          count: n > 0.85 ? 6 : 4,
                          orbitRadius: 55,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Percentage pill ──
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

        // ── Zone dots ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ZoneDot(label: l.zoneDotQuietPlayful, color: const Color(0xFF6BCB77), active: n >= 0.05),
            const SizedBox(width: 6),
            _ZoneDot(label: l.zoneDotGoodPlayful,  color: const Color(0xFFFFD93D), active: n >= 0.40),
            const SizedBox(width: 6),
            _ZoneDot(label: l.zoneDotLoudPlayful,  color: const Color(0xFFFF9F1C), active: n >= 0.65),
            const SizedBox(width: 6),
            _ZoneDot(label: l.zoneDotMaxPlayful,   color: const Color(0xFFFF6B6B), active: n >= 0.85),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Confetti particle
// ═══════════════════════════════════════════════════════════

class _ConfettiParticle {
  final double startX;
  final double offset;
  final double phase;
  final double spin;
  final double size;
  final Color color;
  final bool isCircle;

  static const _colors = [
    Color(0xFFFF6B6B), Color(0xFF6BCB77), Color(0xFFFFD93D),
    Color(0xFF4D96FF), Color(0xFFB66DFF), Color(0xFFFF9F1C),
  ];

  _ConfettiParticle(Random rng)
      : startX    = rng.nextDouble() * 260 + 20,
        offset    = rng.nextDouble(),
        phase     = rng.nextDouble() * pi * 2,
        spin      = rng.nextBool() ? 1 : -1,
        size      = 6.0 + rng.nextDouble() * 8,
        color     = _colors[rng.nextInt(_colors.length)],
        isCircle  = rng.nextBool();
}

// ═══════════════════════════════════════════════════════════
//  Orbit stars painter
// ═══════════════════════════════════════════════════════════

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

// ─── Zone dot ────────────────────────────────────────────
class _ZoneDot extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  const _ZoneDot({required this.label, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.18) : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? color.withOpacity(0.55) : Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
          color: active ? color : Colors.white.withOpacity(0.35))),
    );
  }
}