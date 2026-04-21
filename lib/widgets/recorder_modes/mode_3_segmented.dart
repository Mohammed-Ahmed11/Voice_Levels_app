import 'dart:math';
import 'package:flutter/material.dart';
import 'package:voice_levels_app/l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════
//  Mode 3 — Segmented View (Kids Playful)
// ═══════════════════════════════════════════════════════════

class Mode3SegmentedView extends StatefulWidget {
  final double normalized;
  final Color accent;
  final int segments;
  final int maxLevel;

  const Mode3SegmentedView({
    super.key,
    required this.normalized,
    required this.accent,
    this.segments = 10,
    this.maxLevel = 10,
  });

  @override
  State<Mode3SegmentedView> createState() => _Mode3SegmentedViewState();
}

class _Mode3SegmentedViewState extends State<Mode3SegmentedView>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _bounceCtrl;
  late final AnimationController _floatCtrl;
  double _prevNorm = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _floatCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  }

  @override
  void didUpdateWidget(covariant Mode3SegmentedView old) {
    super.didUpdateWidget(old);
    if (widget.normalized > 0.7 && widget.normalized > _prevNorm + 0.15) {
      _bounceCtrl.forward(from: 0).then((_) => _bounceCtrl.reverse());
    }
    _prevNorm = widget.normalized;
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _bounceCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  // Each segment gets its own color across a gradient spectrum
  Color _segmentColor(int index, int total, double normalizedActive) {
    final ratio = index / (total - 1);
    // Green → Yellow → Orange → Red
    if (ratio < 0.4)  return Color.lerp(const Color(0xFF6BCB77), const Color(0xFFFFD93D), ratio / 0.4)!;
    if (ratio < 0.65) return Color.lerp(const Color(0xFFFFD93D), const Color(0xFFFF9F1C), (ratio - 0.4) / 0.25)!;
    return Color.lerp(const Color(0xFFFF9F1C), const Color(0xFFFF6B6B), (ratio - 0.65) / 0.35)!;
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
    final l = AppLocalizations.of(context)!;
    if (n < 0.25) return l.labelQuiet1;
    if (n < 0.50) return l.labelLouder1;
    if (n < 0.75) return l.labelGreat1;
    return l.labelAmazing1;
  }

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context)!;
    final n      = widget.normalized.clamp(0.0, 1.0);
    final segCount = widget.maxLevel;
    final active = (n * segCount).clamp(0, segCount).toInt();
    final color  = _zoneColor(n);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        // ── Mascot ──
        SizedBox(
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Orbiting stars when loud
              if (n > 0.60)
                AnimatedBuilder(
                  animation: _floatCtrl,
                  builder: (_, __) => CustomPaint(
                    size: const Size(100, 100),
                    painter: _SparklesPainter(progress: _floatCtrl.value, color: color, count: n > 0.80 ? 6 : 3),
                  ),
                ),
              // Bouncing emoji
              AnimatedBuilder(
                animation: _bounceCtrl,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, -sin(_bounceCtrl.value * pi) * 14), child: child!),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                  child: Text(_emoji(n), key: ValueKey(_emoji(n)), style: const TextStyle(fontSize: 50)),
                ),
              ),
            ],
          ),
        ),

        // ── Label ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(_label(context, n), key: ValueKey(_label(context, n)),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color,
              shadows: [Shadow(color: color.withOpacity(0.35), offset: const Offset(0, 2), blurRadius: 6)])),
        ),

        const SizedBox(height: 24),

        // ── Segment bars ──
        SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(segCount, (i) {
              final on      = i < active;
              final segCol  = _segmentColor(i, segCount, n);
              final maxH    = 50.0 + (i / segCount) * 60.0;
              final targetH = on ? maxH : 20.0;
              final isEdge  = on && i == active - 1;

              return AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) {
                  final extra = isEdge ? _pulseCtrl.value * 8 : 0.0;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutBack,
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    width: 16,
                    height: targetH + extra,
                    decoration: BoxDecoration(
                      color: on ? segCol : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: on
                          ? [
                              BoxShadow(color: segCol, blurRadius: 0, offset: const Offset(0, 4)),
                              BoxShadow(color: segCol.withOpacity(0.40), blurRadius: 14, offset: const Offset(0, 8)),
                            ]
                          : [],
                    ),
                    // Shine on active bars
                    child: on
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 4, left: 4, right: 4),
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.30),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          )
                        : null,
                  );
                },
              );
            }),
          ),
        ),

        const SizedBox(height: 6),

        // ── Floor line ──
        Container(
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        const SizedBox(height: 20),

        // ── Percentage pill ──
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (_, __) => Transform.scale(
            scale: n > 0.8 ? 1.0 + _pulseCtrl.value * 0.08 : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                children: [
                  Text('$active/${widget.maxLevel}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20,
                      shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)])),
                  const SizedBox(width: 8),
                  Text(l.meterBars, style: TextStyle(color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.w700, fontSize: 14)),
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
            _ZoneDot(label: l.zoneQuiet, color: const Color(0xFF6BCB77), active: n >= 0.05),
            const SizedBox(width: 8),
            _ZoneDot(label: l.zoneGood,  color: const Color(0xFFFFD93D), active: n >= 0.40),
            const SizedBox(width: 8),
            _ZoneDot(label: l.zoneLoud,  color: const Color(0xFFFF9F1C), active: n >= 0.65),
            const SizedBox(width: 8),
            _ZoneDot(label: l.zoneMax,   color: const Color(0xFFFF6B6B), active: n >= 0.85),
          ],
        ),
      ],
    );
  }
}

// ── Sparkles painter ─────────────────────────────────────
class _SparklesPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int count;
  const _SparklesPainter({required this.progress, required this.color, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2; final cy = size.height / 2;
    final paint = Paint()..color = color.withOpacity(0.90);
    for (int i = 0; i < count; i++) {
      final angle = (progress * 2 * pi) + (i * 2 * pi / count);
      final r = 44.0;
      final x = cx + r * cos(angle); final y = cy + r * sin(angle);
      _drawStar(canvas, Offset(x, y), i % 2 == 0 ? 5.0 : 3.5, paint);
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
  bool shouldRepaint(covariant _SparklesPainter old) => old.progress != progress || old.color != color;
}

// ── Zone dot ─────────────────────────────────────────────
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