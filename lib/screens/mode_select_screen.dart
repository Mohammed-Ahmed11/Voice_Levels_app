import 'dart:math';
import 'package:flutter/material.dart';
import '../routes.dart';

// ═══════════════════════════════════════════════════════════
//  ModeSelectScreen — Kids Cartoon UI (Animals on cards + BG)
// ═══════════════════════════════════════════════════════════

class ModeSelectScreen extends StatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgFloat1;
  late final AnimationController _bgFloat2;
  late final AnimationController _bgFloat3;
  late final AnimationController _bgFloat4;
  late final List<AnimationController> _cardControllers;
  late final List<Animation<double>> _cardFades;
  late final List<Animation<Offset>> _cardSlides;

  final List<_ModeData> _modes = const [
    _ModeData(
      id: '1',
      title: 'Classic',
      desc: 'Simple level meter',
      animal: _Animal.bear,
      bgColor: Color(0xFF4D96FF),
      accentColor: Color(0xFF82B8FF),
      shadowColor: Color(0xFF2260CC),
      bgImage: 'assets/images/mode-1.png',
      overlay: 0.30,
    ),
    _ModeData(
      id: '2',
      title: 'Rounded',
      desc: 'Smooth rounded meter',
      animal: _Animal.duck,
      bgColor: Color(0xFFFF9F1C),
      accentColor: Color(0xFFFFBF6A),
      shadowColor: Color(0xFFCC7A00),
      bgImage: 'assets/images/mode-2.png',
      overlay: 0.32,
    ),
    _ModeData(
      id: '3',
      title: 'Thick Meter',
      desc: 'Bold & clear levels',
      animal: _Animal.cat,
      bgColor: Color(0xFFB66DFF),
      accentColor: Color(0xFFCE99FF),
      shadowColor: Color(0xFF7A30CC),
      bgImage: 'assets/images/mode-3.png',
      overlay: 0.34,
    ),
    _ModeData(
      id: '4',
      title: 'Playful',
      desc: 'Fun child-friendly UI',
      animal: _Animal.bunny,
      bgColor: Color(0xFF6BCB77),
      accentColor: Color(0xFF96DFA0),
      shadowColor: Color(0xFF3A9947),
      bgImage: 'assets/images/mode-4.png',
      overlay: 0.28,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Independent float controllers for each background animal
    _bgFloat1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat(reverse: true);
    _bgFloat2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2700))..repeat(reverse: true);
    _bgFloat3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat(reverse: true);
    _bgFloat4 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);

    _cardControllers = List.generate(
      _modes.length,
      (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 540)),
    );
    _cardFades = _cardControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _cardSlides = _cardControllers
        .map((c) => Tween<Offset>(begin: const Offset(0, 0.26), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)))
        .toList();

    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 160 + i * 120), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _bgFloat1.dispose();
    _bgFloat2.dispose();
    _bgFloat3.dispose();
    _bgFloat4.dispose();
    for (final c in _cardControllers) c.dispose();
    super.dispose();
  }

  Widget _bgAnimal({
    required AnimationController ctrl,
    required CustomPainter painter,
    required double size,
    required double opacity,
    required double angle,
    required double baseTop,
    required double? left,
    required double? right,
  }) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Positioned(
        top: baseTop + sin(ctrl.value * pi) * 10,
        left: left,
        right: right,
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: angle,
            child: CustomPaint(size: Size(size, size), painter: painter),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E8),
      body: Stack(
        children: [
          // ── Pastel background blobs ──
          Positioned(top: -70, left: -50, child: _Blob(color: const Color(0xFFD6ECFF), size: 250)),
          Positioned(top: 80, right: -60, child: _Blob(color: const Color(0xFFFFDFDF), size: 200)),
          Positioned(bottom: 130, left: -50, child: _Blob(color: const Color(0xFFD6FFE4), size: 210)),
          Positioned(bottom: -50, right: 0, child: _Blob(color: const Color(0xFFFFF0C8), size: 180)),

          // ── Floating background animals ──
          _bgAnimal(
            ctrl: _bgFloat1,
            painter: _BearPainter(color: const Color(0xFF4D96FF)),
            size: 110,
            opacity: 0.13,
            angle: -0.25,
            baseTop: 80,
            left: -20,
            right: null,
          ),
          _bgAnimal(
            ctrl: _bgFloat2,
            painter: _DuckPainter(color: const Color(0xFFFF9F1C)),
            size: 95,
            opacity: 0.14,
            angle: 0.20,
            baseTop: 60,
            left: null,
            right: -22,
          ),
          _bgAnimal(
            ctrl: _bgFloat3,
            painter: _BunnyPainter(color: const Color(0xFF6BCB77)),
            size: 100,
            opacity: 0.13,
            angle: -0.15,
            baseTop: 440,
            left: -18,
            right: null,
          ),
          _bgAnimal(
            ctrl: _bgFloat4,
            painter: _CatPainter(color: const Color(0xFFB66DFF)),
            size: 92,
            opacity: 0.13,
            angle: 0.22,
            baseTop: 400,
            left: null,
            right: -18,
          ),

          // ── Main UI ──
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: Color(0xFF3D3D3D)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Pick a ',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF3D3D3D),
                                  ),
                                ),
                                TextSpan(
                                  text: 'Mode!',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF9C8AE6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Each mode has a different look & feel ✨',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Cards grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.80,
                      ),
                      itemCount: _modes.length,
                      itemBuilder: (context, i) {
                        return FadeTransition(
                          opacity: _cardFades[i],
                          child: SlideTransition(
                            position: _cardSlides[i],
                            child: _ModeCard(
                              data: _modes[i],
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.recorder,
                                arguments: {
                                  'modeId': _modes[i].id,
                                  'bg': _modes[i].bgImage,
                                  'accent': _modes[i].bgColor,
                                  'overlay': _modes[i].overlay,
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Bottom nav
                _BottomBar(screenContext: context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Mode Card  — animal is the STAR of the card
// ═══════════════════════════════════════════════════════════

class _ModeCard extends StatefulWidget {
  final _ModeData data;
  final VoidCallback onTap;

  const _ModeCard({required this.data, required this.onTap});

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final AnimationController _animalBounce;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.91)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

    // Gentle idle bounce for the animal character
    _animalBounce = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800 + (widget.data.id.hashCode % 600)),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animalBounce, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _animalBounce.dispose();
    super.dispose();
  }

  CustomPainter _painterFor(_Animal animal) {
    switch (animal) {
      case _Animal.bear:  return const _BearPainter(color: Colors.white);
      case _Animal.duck:  return const _DuckPainter(color: Colors.white);
      case _Animal.cat:   return const _CatPainter(color: Colors.white);
      case _Animal.bunny: return const _BunnyPainter(color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) { _pressCtrl.reverse(); widget.onTap(); },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: widget.data.bgColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              // Hard cartoon shadow
              BoxShadow(
                color: widget.data.shadowColor,
                blurRadius: 0,
                offset: const Offset(0, 7),
              ),
              // Soft ambient
              BoxShadow(
                color: widget.data.shadowColor.withOpacity(0.32),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // Wavy top strip (lighter shade)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: CustomPaint(
                    size: const Size(double.infinity, 52),
                    painter: _WavePainter(widget.data.accentColor),
                  ),
                ),

                // ── BIG Animal character — center stage ──
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _bounceAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, sin(_bounceAnim.value * pi) * 6),
                      child: child,
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(110, 110),
                        painter: _painterFor(widget.data.animal),
                      ),
                    ),
                  ),
                ),

                // Shadow under animal for grounded feel
                Positioned(
                  top: 102,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _bounceAnim,
                      builder: (_, __) {
                        final scale = 0.7 + sin(_bounceAnim.value * pi) * 0.15;
                        return Transform.scale(
                          scaleX: scale,
                          scaleY: 1.0,
                          child: Container(
                            width: 60,
                            height: 10,
                            decoration: BoxDecoration(
                              color: widget.data.shadowColor.withOpacity(0.28),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Text content at bottom
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // Mode number badge
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.30),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.55),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  widget.data.id,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.data.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                                shadows: [
                                  Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.data.desc,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Play pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.28),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.45)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Tap to use',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Bottom Nav Bar
// ═══════════════════════════════════════════════════════════

class _BottomBar extends StatelessWidget {
  final BuildContext screenContext;
  const _BottomBar({required this.screenContext});

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(emoji: '🏠', label: 'Home',
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    screenContext, AppRoutes.home, (r) => false)),
            _NavItem(emoji: '🎵', label: 'Records',
                onTap: () => Navigator.pushNamed(screenContext, AppRoutes.recordings)),
            _NavItem(emoji: '⚙️', label: 'Options',
                onTap: () => Navigator.pushNamed(screenContext, AppRoutes.settings)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.emoji, required this.label, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            color: _pressed ? Colors.white.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 3),
              Text(widget.label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.85),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Animal Painters  (all drawn with CustomPainter)
// ═══════════════════════════════════════════════════════════

// ── Bear ─────────────────────────────────────────────────────────────────────
class _BearPainter extends CustomPainter {
  final Color color;
  const _BearPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p     = Paint()..color = color..style = PaintingStyle.fill;
    final dark  = Paint()..color = color.withOpacity(0.55);
    final white = Paint()..color = Colors.white.withOpacity(0.92);
    final black = Paint()..color = const Color(0xFF1A1A1A);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.34;

    // Ears
    canvas.drawCircle(Offset(cx - r * 0.68, cy - r * 0.74), r * 0.36, p);
    canvas.drawCircle(Offset(cx + r * 0.68, cy - r * 0.74), r * 0.36, p);
    canvas.drawCircle(Offset(cx - r * 0.68, cy - r * 0.74), r * 0.20, dark);
    canvas.drawCircle(Offset(cx + r * 0.68, cy - r * 0.74), r * 0.20, dark);
    // Head
    canvas.drawCircle(Offset(cx, cy), r, p);
    // Muzzle
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + r * 0.34), width: r * 0.96, height: r * 0.60),
      dark,
    );
    // Eyes
    canvas.drawCircle(Offset(cx - r * 0.34, cy - r * 0.14), r * 0.15, white);
    canvas.drawCircle(Offset(cx + r * 0.34, cy - r * 0.14), r * 0.15, white);
    canvas.drawCircle(Offset(cx - r * 0.32, cy - r * 0.12), r * 0.09, black);
    canvas.drawCircle(Offset(cx + r * 0.32, cy - r * 0.12), r * 0.09, black);
    // Eye shine
    canvas.drawCircle(Offset(cx - r * 0.27, cy - r * 0.17), r * 0.04, white);
    canvas.drawCircle(Offset(cx + r * 0.37, cy - r * 0.17), r * 0.04, white);
    // Nose
    canvas.drawCircle(Offset(cx, cy + r * 0.18), r * 0.11, black);
    // Smile
    final smile = Path()
      ..moveTo(cx - r * 0.22, cy + r * 0.30)
      ..quadraticBezierTo(cx, cy + r * 0.52, cx + r * 0.22, cy + r * 0.30);
    canvas.drawPath(smile, Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.040
      ..strokeCap = StrokeCap.round);
    // Cheek blush
    canvas.drawCircle(Offset(cx - r * 0.58, cy + r * 0.16), r * 0.16,
        Paint()..color = Colors.pink.withOpacity(0.38));
    canvas.drawCircle(Offset(cx + r * 0.58, cy + r * 0.16), r * 0.16,
        Paint()..color = Colors.pink.withOpacity(0.38));
  }

  @override
  bool shouldRepaint(covariant _BearPainter old) => old.color != color;
}

// ── Duck ─────────────────────────────────────────────────────────────────────
class _DuckPainter extends CustomPainter {
  final Color color;
  const _DuckPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p      = Paint()..color = color..style = PaintingStyle.fill;
    final white  = Paint()..color = Colors.white.withOpacity(0.92);
    final black  = Paint()..color = const Color(0xFF1A1A1A);
    final orange = Paint()..color = const Color(0xFFFF8C00);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.30;

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + r * 0.55), width: r * 1.6, height: r * 1.2),
      p,
    );
    // Wing highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + r * 0.28, cy + r * 0.72), width: r * 0.9, height: r * 0.55),
      Paint()..color = color.withOpacity(0.50),
    );
    // Head
    canvas.drawCircle(Offset(cx, cy - r * 0.08), r, p);
    // Head feather tuft
    final tuft = Path()
      ..moveTo(cx - r * 0.10, cy - r * 0.94)
      ..quadraticBezierTo(cx + r * 0.04, cy - r * 1.45, cx + r * 0.18, cy - r * 0.96)
      ..close();
    canvas.drawPath(tuft, p);
    // Beak
    final beak = Path()
      ..moveTo(cx + r * 0.80, cy - r * 0.06)
      ..lineTo(cx + r * 1.25, cy + r * 0.06)
      ..lineTo(cx + r * 0.80, cy + r * 0.20)
      ..close();
    canvas.drawPath(beak, orange);
    // Eye
    canvas.drawCircle(Offset(cx + r * 0.30, cy - r * 0.20), r * 0.16, white);
    canvas.drawCircle(Offset(cx + r * 0.32, cy - r * 0.18), r * 0.09, black);
    canvas.drawCircle(Offset(cx + r * 0.37, cy - r * 0.22), r * 0.04, white);
    // Blush
    canvas.drawCircle(Offset(cx + r * 0.52, cy + r * 0.10), r * 0.14,
        Paint()..color = Colors.pink.withOpacity(0.40));
  }

  @override
  bool shouldRepaint(covariant _DuckPainter old) => old.color != color;
}

// ── Cat ──────────────────────────────────────────────────────────────────────
class _CatPainter extends CustomPainter {
  final Color color;
  const _CatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p     = Paint()..color = color..style = PaintingStyle.fill;
    final white = Paint()..color = Colors.white.withOpacity(0.92);
    final black = Paint()..color = const Color(0xFF1A1A1A);
    final pink  = Paint()..color = const Color(0xFFFFB3C6);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.30;

    // Ears
    final lEar = Path()
      ..moveTo(cx - r * 0.60, cy - r * 0.60)
      ..lineTo(cx - r * 1.00, cy - r * 1.22)
      ..lineTo(cx - r * 0.16, cy - r * 0.94)
      ..close();
    final rEar = Path()
      ..moveTo(cx + r * 0.60, cy - r * 0.60)
      ..lineTo(cx + r * 1.00, cy - r * 1.22)
      ..lineTo(cx + r * 0.16, cy - r * 0.94)
      ..close();
    canvas.drawPath(lEar, p);
    canvas.drawPath(rEar, p);
    // Inner ear
    final liEar = Path()
      ..moveTo(cx - r * 0.60, cy - r * 0.70)
      ..lineTo(cx - r * 0.86, cy - r * 1.10)
      ..lineTo(cx - r * 0.28, cy - r * 0.92)
      ..close();
    final riEar = Path()
      ..moveTo(cx + r * 0.60, cy - r * 0.70)
      ..lineTo(cx + r * 0.86, cy - r * 1.10)
      ..lineTo(cx + r * 0.28, cy - r * 0.92)
      ..close();
    canvas.drawPath(liEar, pink);
    canvas.drawPath(riEar, pink);
    // Head
    canvas.drawCircle(Offset(cx, cy), r, p);
    // Eyes (oval cat eyes)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.35, cy - r * 0.10), width: r * 0.34, height: r * 0.28), white);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.35, cy - r * 0.10), width: r * 0.34, height: r * 0.28), white);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.35, cy - r * 0.10), width: r * 0.11, height: r * 0.24), black);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.35, cy - r * 0.10), width: r * 0.11, height: r * 0.24), black);
    canvas.drawCircle(Offset(cx - r * 0.28, cy - r * 0.16), r * 0.05, white);
    canvas.drawCircle(Offset(cx + r * 0.42, cy - r * 0.16), r * 0.05, white);
    // Nose
    final nose = Path()
      ..moveTo(cx, cy + r * 0.10)
      ..lineTo(cx - r * 0.11, cy + r * 0.22)
      ..lineTo(cx + r * 0.11, cy + r * 0.22)
      ..close();
    canvas.drawPath(nose, pink);
    // Whiskers
    final wPaint = Paint()
      ..color = white.color
      ..strokeWidth = size.width * 0.028
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final d in [-1.0, 1.0]) {
      canvas.drawLine(Offset(cx + d * r * 0.14, cy + r * 0.22), Offset(cx + d * r * 0.90, cy + r * 0.10), wPaint);
      canvas.drawLine(Offset(cx + d * r * 0.14, cy + r * 0.30), Offset(cx + d * r * 0.90, cy + r * 0.38), wPaint);
    }
    // Smile
    final smile = Path()
      ..moveTo(cx - r * 0.16, cy + r * 0.28)
      ..quadraticBezierTo(cx, cy + r * 0.46, cx + r * 0.16, cy + r * 0.28);
    canvas.drawPath(smile, Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.038
      ..strokeCap = StrokeCap.round);
    // Blush
    canvas.drawCircle(Offset(cx - r * 0.58, cy + r * 0.18), r * 0.16, Paint()..color = Colors.pink.withOpacity(0.35));
    canvas.drawCircle(Offset(cx + r * 0.58, cy + r * 0.18), r * 0.16, Paint()..color = Colors.pink.withOpacity(0.35));
  }

  @override
  bool shouldRepaint(covariant _CatPainter old) => old.color != color;
}

// ── Bunny ────────────────────────────────────────────────────────────────────
class _BunnyPainter extends CustomPainter {
  final Color color;
  const _BunnyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p     = Paint()..color = color..style = PaintingStyle.fill;
    final white = Paint()..color = Colors.white.withOpacity(0.92);
    final black = Paint()..color = const Color(0xFF1A1A1A);
    final pink  = Paint()..color = const Color(0xFFFFB3C6);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.30;

    // Long ears
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - r * 0.40, cy - r * 1.28), width: r * 0.46, height: r * 1.08),
      const Radius.circular(30)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + r * 0.40, cy - r * 1.28), width: r * 0.46, height: r * 1.08),
      const Radius.circular(30)), p);
    // Inner ear
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - r * 0.40, cy - r * 1.28), width: r * 0.22, height: r * 0.76),
      const Radius.circular(20)), pink);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + r * 0.40, cy - r * 1.28), width: r * 0.22, height: r * 0.76),
      const Radius.circular(20)), pink);
    // Head
    canvas.drawCircle(Offset(cx, cy), r, p);
    // Cheeks
    canvas.drawCircle(Offset(cx - r * 0.52, cy + r * 0.20), r * 0.22, Paint()..color = Colors.pink.withOpacity(0.38));
    canvas.drawCircle(Offset(cx + r * 0.52, cy + r * 0.20), r * 0.22, Paint()..color = Colors.pink.withOpacity(0.38));
    // Eyes
    canvas.drawCircle(Offset(cx - r * 0.32, cy - r * 0.10), r * 0.15, white);
    canvas.drawCircle(Offset(cx + r * 0.32, cy - r * 0.10), r * 0.15, white);
    canvas.drawCircle(Offset(cx - r * 0.30, cy - r * 0.08), r * 0.09, black);
    canvas.drawCircle(Offset(cx + r * 0.30, cy - r * 0.08), r * 0.09, black);
    canvas.drawCircle(Offset(cx - r * 0.24, cy - r * 0.14), r * 0.04, white);
    canvas.drawCircle(Offset(cx + r * 0.36, cy - r * 0.14), r * 0.04, white);
    // Nose
    canvas.drawCircle(Offset(cx, cy + r * 0.17), r * 0.11, pink);
    // Smile
    final smile = Path()
      ..moveTo(cx - r * 0.22, cy + r * 0.32)
      ..quadraticBezierTo(cx, cy + r * 0.52, cx + r * 0.22, cy + r * 0.32);
    canvas.drawPath(smile, Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.040
      ..strokeCap = StrokeCap.round);
    // Little tail hint (optional bottom)
    canvas.drawCircle(Offset(cx + r * 0.80, cy + r * 0.68), r * 0.18, white);
  }

  @override
  bool shouldRepaint(covariant _BunnyPainter old) => old.color != color;
}

// ═══════════════════════════════════════════════════════════
//  Wave Painter
// ═══════════════════════════════════════════════════════════

class _WavePainter extends CustomPainter {
  final Color color;
  const _WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 28)
      ..quadraticBezierTo(size.width * 0.75, 52, size.width * 0.5, 38)
      ..quadraticBezierTo(size.width * 0.25, 22, 0, 48)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ═══════════════════════════════════════════════════════════
//  Data & Helpers
// ═══════════════════════════════════════════════════════════

enum _Animal { bear, duck, cat, bunny }

class _ModeData {
  final String id;
  final String title;
  final String desc;
  final _Animal animal;
  final Color bgColor;
  final Color accentColor;
  final Color shadowColor;
  final String bgImage;
  final double overlay;

  const _ModeData({
    required this.id,
    required this.title,
    required this.desc,
    required this.animal,
    required this.bgColor,
    required this.accentColor,
    required this.shadowColor,
    required this.bgImage,
    required this.overlay,
  });
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}