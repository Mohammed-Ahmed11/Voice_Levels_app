import 'dart:math';
import 'package:flutter/material.dart';
import 'package:voice_levels_app/l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════
//  Mode 1 — Classic View (Kids Playful)
// ═══════════════════════════════════════════════════════════
//
//  normalized : 0.0 → 1.0  (current audio level)
//  accent     : theme color passed from recorder screen
//
// ═══════════════════════════════════════════════════════════

class Mode1ClassicView extends StatefulWidget {
  final double normalized;
  final Color accent;

  /// Max level ceiling from AppSettings (10 or 20).
  /// Used to label the percentage readout and zone thresholds.
  final int maxLevel;

  const Mode1ClassicView({
    super.key,
    required this.normalized,
    required this.accent,
    this.maxLevel = 10,
  });

  @override
  State<Mode1ClassicView> createState() => _Mode1ClassicViewState();
}

class _Mode1ClassicViewState extends State<Mode1ClassicView>
    with TickerProviderStateMixin {
  // Mascot bounce when level is high
  late final AnimationController _bounceCtrl;
  late final AnimationController _starCtrl; // rotating stars
  late final AnimationController _pulseCtrl; // glow pulse

  // Remember previous normalized to detect big jumps (cheer effect)
  double _prevNormalized = 0;

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      lowerBound: 0,
      upperBound: 1,
    );

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant Mode1ClassicView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Bounce mascot on loud input
    if (widget.normalized > 0.6 && widget.normalized > _prevNormalized + 0.1) {
      _bounceCtrl.forward(from: 0).then((_) => _bounceCtrl.reverse());
    }
    _prevNormalized = widget.normalized;
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _starCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // Zone color: green → yellow → orange → red
  Color _zoneColor(double n) {
    if (n < 0.4) return const Color(0xFF6BCB77);
    if (n < 0.65) return const Color(0xFFFFD93D);
    if (n < 0.85) return const Color(0xFFFF9F1C);
    return const Color(0xFFFF6B6B);
  }

  String _mascotEmoji(double n) {
    if (n < 0.25) return '😴';
    if (n < 0.50) return '😊';
    if (n < 0.75) return '😄';
    return '🤩';
  }

  // ✅ استخدام AppLocalizations بدل الـ hardcoded strings
  String _levelLabel(double n, AppLocalizations l10n) {
    if (n < 0.25) return l10n.labelQuiet1;
    if (n < 0.50) return l10n.labelLouder1;
    if (n < 0.75) return l10n.labelGreat1;
    return l10n.labelAmazing1;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ جلب الـ localizations مرة واحدة في البداية
    final l10n = AppLocalizations.of(context)!;

    final n = widget.normalized.clamp(0.0, 1.0);
    final color = _zoneColor(n);
    final w = MediaQuery.of(context).size.width - 32; // minus padding

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Mascot + stars ──
        SizedBox(
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating star sparkles (only when loud)
              if (n > 0.5)
                AnimatedBuilder(
                  animation: _starCtrl,
                  builder: (_, __) {
                    return CustomPaint(
                      size: const Size(120, 120),
                      painter: _StarOrbitPainter(
                        progress: _starCtrl.value,
                        color: color,
                        count: n > 0.75 ? 6 : 4,
                      ),
                    );
                  },
                ),

              // Bouncing mascot
              AnimatedBuilder(
                animation: _bounceCtrl,
                builder: (_, child) {
                  final dy = -sin(_bounceCtrl.value * pi) * 14;
                  return Transform.translate(
                      offset: Offset(0, dy), child: child);
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Text(
                    _mascotEmoji(n),
                    key: ValueKey(_mascotEmoji(n)),
                    style: const TextStyle(fontSize: 52),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Level label ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            _levelLabel(n, l10n),
            key: ValueKey(_levelLabel(n, l10n)),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.3,
              shadows: [
                Shadow(
                    color: color.withOpacity(0.35),
                    offset: const Offset(0, 2),
                    blurRadius: 6),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Main progress bar track ──
        Container(
          height: 28,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withOpacity(0.30), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Filled portion
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 28,
                width: w * n,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _zoneColor(0),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.55),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),

              // Glowing tip
              if (n > 0.02)
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) {
                    final glowOpacity = 0.4 + _pulseCtrl.value * 0.4;
                    return Positioned(
                      left: (w * n - 18).clamp(0, w - 18),
                      top: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(glowOpacity),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(glowOpacity),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Shine overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.28),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Segmented zone indicators ──
        Row(
          children: [
            // ✅ النصوص جاية من الـ ARB
            _ZoneDot(
                label: l10n.zoneQuiet,
                color: const Color(0xFF6BCB77),
                active: n >= 0.05),
            const SizedBox(width: 6),
            _ZoneDot(
                label: l10n.zoneGood,
                color: const Color(0xFFFFD93D),
                active: n >= 0.40),
            const SizedBox(width: 6),
            _ZoneDot(
                label: l10n.zoneLoud,
                color: const Color(0xFFFF9F1C),
                active: n >= 0.65),
            const SizedBox(width: 6),
            _ZoneDot(
                label: l10n.zoneMax,
                color: const Color(0xFFFF6B6B),
                active: n >= 0.85),
          ],
        ),

        const SizedBox(height: 16),

        // ── Percentage readout ──
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) {
            final scale = n > 0.8 ? 1.0 + _pulseCtrl.value * 0.08 : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: color,
                        blurRadius: 0,
                        offset: const Offset(0, 4)),
                    BoxShadow(
                        color: color.withOpacity(0.30),
                        blurRadius: 14,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${(n * widget.maxLevel).round()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        shadows: [
                          Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4)
                        ],
                      ),
                    ),
                    Text(
                      ' / ${widget.maxLevel}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.70),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Zone dot indicator
// ═══════════════════════════════════════════════════════════

class _ZoneDot extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;

  const _ZoneDot(
      {required this.label, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color:
              active ? color.withOpacity(0.18) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? color.withOpacity(0.55)
                : Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? color : Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                boxShadow: active ? [BoxShadow(color: color, blurRadius: 6)] : [],
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: active ? color : Colors.white.withOpacity(0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Star orbit painter
// ═══════════════════════════════════════════════════════════

class _StarOrbitPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int count;

  const _StarOrbitPainter({
    required this.progress,
    required this.color,
    required this.count,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const orbitR = 52.0;

    final paint = Paint()..color = color.withOpacity(0.85);

    for (int i = 0; i < count; i++) {
      final angle = (progress * 2 * pi) + (i * 2 * pi / count);
      final x = cx + orbitR * cos(angle);
      final y = cy + orbitR * sin(angle);

      // Alternating star sizes
      final starR = i % 2 == 0 ? 5.0 : 3.5;
      _drawStar(canvas, Offset(x, y), starR, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    const points = 4;
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? r : r * 0.45;
      final angle = (i * pi / points) - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarOrbitPainter old) =>
      old.progress != progress || old.color != color || old.count != count;
}