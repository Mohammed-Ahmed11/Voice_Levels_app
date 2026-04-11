import 'dart:math';
import 'package:flutter/material.dart';
import '../routes.dart';

// ═══════════════════════════════════════════════════════════
//  ModeSelectScreen — Kids Cartoon UI (Improved)
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
  late final AnimationController _headerAnim;
  late final List<AnimationController> _cardControllers;
  late final List<Animation<double>> _cardFades;
  late final List<Animation<Offset>> _cardSlides;

  final List<_ModeData> _modes = const [
    _ModeData(
      id: '1',
      title: 'Classic',
      desc: 'Simple level meter',
      animal: _Animal.bear,
      bgColor: Color(0xFF3A86FF),
      accentColor: Color(0xFF6AAEFF),
      shadowColor: Color(0xFF1A5CC8),
      bgImage: 'assets/images/mode-1.png',
      overlay: 0.30,
      tagEmoji: '⚡',
      tagLabel: 'Popular',
    ),
    _ModeData(
      id: '2',
      title: 'Rounded',
      desc: 'Smooth rounded meter',
      animal: _Animal.duck,
      bgColor: Color(0xFFFF9F1C),
      accentColor: Color(0xFFFFBF6A),
      shadowColor: Color(0xFFB86A00),
      bgImage: 'assets/images/mode-2.png',
      overlay: 0.32,
      tagEmoji: '✨',
      tagLabel: 'Smooth',
    ),
    _ModeData(
      id: '3',
      title: 'Thick Meter',
      desc: 'Bold & clear levels',
      animal: _Animal.cat,
      bgColor: Color(0xFFAB5CF7),
      accentColor: Color(0xFFC98AF9),
      shadowColor: Color(0xFF6B22B0),
      bgImage: 'assets/images/mode-3.png',
      overlay: 0.34,
      tagEmoji: '💪',
      tagLabel: 'Bold',
    ),
    _ModeData(
      id: '4',
      title: 'Playful',
      desc: 'Fun child-friendly UI',
      animal: _Animal.bunny,
      bgColor: Color(0xFF2ECC71),
      accentColor: Color(0xFF65DBA0),
      shadowColor: Color(0xFF1A8A4A),
      bgImage: 'assets/images/mode-4.png',
      overlay: 0.28,
      tagEmoji: '🎉',
      tagLabel: 'Fun',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();

    _bgFloat1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat(reverse: true);
    _bgFloat2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2700))..repeat(reverse: true);
    _bgFloat3 = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat(reverse: true);
    _bgFloat4 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);

    _cardControllers = List.generate(
      _modes.length,
      (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 560)),
    );

    _cardFades = _cardControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _cardSlides = _cardControllers
        .map((c) => Tween<Offset>(begin: const Offset(0, 0.30), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)))
        .toList();

    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + i * 110), () {
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
    _headerAnim.dispose();
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
        top: baseTop + sin(ctrl.value * pi) * 12,
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
      backgroundColor: const Color(0xFFFFF6ED),
      body: Stack(
        children: [
          // Background blobs — more varied sizes and positions
          Positioned(top: -90, left: -60, child: _Blob(color: const Color(0xFFCFE5FF), size: 280)),
          Positioned(top: 100, right: -70, child: _Blob(color: const Color(0xFFFFDDDD), size: 220)),
          Positioned(bottom: 160, left: -60, child: _Blob(color: const Color(0xFFC9F7DE), size: 240)),
          Positioned(bottom: -60, right: -20, child: _Blob(color: const Color(0xFFFFF0C8), size: 200)),
          // Extra tiny accent blobs
          Positioned(top: 280, left: 80, child: _Blob(color: const Color(0xFFFDE8FF), size: 90)),
          Positioned(top: 350, right: 60, child: _Blob(color: const Color(0xFFDFF5FF), size: 70)),

          // Background dot pattern
          Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

          // Background floating animals
          _bgAnimal(
            ctrl: _bgFloat1,
            painter: _BearPainter(color: const Color(0xFF3A86FF)),
            size: 115,
            opacity: 0.11,
            angle: -0.25,
            baseTop: 90,
            left: -22,
            right: null,
          ),
          _bgAnimal(
            ctrl: _bgFloat2,
            painter: _DuckPainter(color: const Color(0xFFFF9F1C)),
            size: 100,
            opacity: 0.12,
            angle: 0.20,
            baseTop: 60,
            left: null,
            right: -24,
          ),
          _bgAnimal(
            ctrl: _bgFloat3,
            painter: _BunnyPainter(color: const Color(0xFF2ECC71)),
            size: 105,
            opacity: 0.11,
            angle: -0.15,
            baseTop: 450,
            left: -20,
            right: null,
          ),
          _bgAnimal(
            ctrl: _bgFloat4,
            painter: _CatPainter(color: const Color(0xFFAB5CF7)),
            size: 96,
            opacity: 0.11,
            angle: 0.22,
            baseTop: 420,
            left: null,
            right: -20,
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                FadeTransition(
                  opacity: CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut),
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
                        .animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutBack)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(
                        children: [
                          _BackButton(onTap: () => Navigator.pop(context)),
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
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2D2D2D),
                                        height: 1.1,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Mode!',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF9C8AE6 ),
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2ECC71),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '4 unique looks to choose from',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.78,
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

                const SizedBox(height: 10),
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

// ─── Back Button ──────────────────────────────────────────
class _BackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.09),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF3D3D3D)),
        ),
      ),
    );
  }
}

// ─── Mode Card ────────────────────────────────────────────
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
  late final AnimationController _shimmer;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _bounceAnim;

  static const Color _animalColor = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

    _animalBounce = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1900 + (widget.data.id.hashCode % 500)),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animalBounce, curve: Curves.easeInOut));

    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _animalBounce.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  CustomPainter _painterFor(_Animal animal) {
    switch (animal) {
      case _Animal.bear:
        return const _BearPainter(color: _animalColor);
      case _Animal.duck:
        return const _DuckPainter(color: _animalColor);
      case _Animal.cat:
        return const _CatPainter(color: _animalColor);
      case _Animal.bunny:
        return const _BunnyPainter(color: _animalColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.data.bgColor,
                widget.data.shadowColor,
              ],
            ),
            boxShadow: [
              // Hard offset shadow (cartoon style)
              BoxShadow(
                color: widget.data.shadowColor,
                blurRadius: 0,
                offset: const Offset(0, 6),
              ),
              // Soft glow
              BoxShadow(
                color: widget.data.bgColor.withOpacity(0.45),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Decorative circle shapes in background
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: -15,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 70,
                  left: -20,
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Sparkle dots
                Positioned(top: 12, right: 14, child: _Sparkle(color: Colors.white.withOpacity(0.70), size: 7)),
                Positioned(top: 30, right: 36, child: _Sparkle(color: Colors.white.withOpacity(0.40), size: 5)),
                Positioned(top: 8, left: 16, child: _Sparkle(color: Colors.white.withOpacity(0.35), size: 4)),

                // Tag badge (top-left)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.data.tagEmoji, style: const TextStyle(fontSize: 10)),
                        const SizedBox(width: 3),
                        Text(
                          widget.data.tagLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Animal with bounce
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _bounceAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, sin(_bounceAnim.value * pi) * 7),
                      child: child,
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(108, 108),
                        painter: _painterFor(widget.data.animal),
                      ),
                    ),
                  ),
                ),

                // Shadow under animal (squish effect)
                Positioned(
                  top: 106,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _bounceAnim,
                      builder: (_, __) {
                        final progress = sin(_bounceAnim.value * pi);
                        final scaleX = 0.65 + progress * 0.20;
                        final opacity = 0.18 + progress * 0.08;
                        return Transform.scale(
                          scaleX: scaleX,
                          scaleY: 1.0,
                          child: Container(
                            width: 56,
                            height: 9,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(opacity),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Bottom info panel
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.28),
                          Colors.black.withOpacity(0.38),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mode number + title
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.60), width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  widget.data.id,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                widget.data.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                  shadows: [
                                    Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 4)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.data.desc,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 9),
                        // CTA button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.24),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.50), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 13),
                              SizedBox(width: 4),
                              Text('Tap to use',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.1)),
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

// ─── Sparkle widget ───────────────────────────────────────
class _Sparkle extends StatelessWidget {
  final Color color;
  final double size;
  const _Sparkle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final BuildContext screenContext;
  const _BottomBar({required this.screenContext});

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 22,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
                emoji: '🏠',
                label: 'Home',
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    screenContext, AppRoutes.home, (r) => false)),
            _NavDivider(),
            _NavItem(
                emoji: '🎵',
                label: 'Records',
                onTap: () => Navigator.pushNamed(
                    screenContext, AppRoutes.recordings)),
            _NavDivider(),
            _NavItem(
                emoji: '⚙️',
                label: 'Options',
                onTap: () =>
                    Navigator.pushNamed(screenContext, AppRoutes.settings)),
          ],
        ),
      ),
    );
  }
}

class _NavDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withOpacity(0.10),
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
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            color: _pressed
                ? Colors.white.withOpacity(0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 21)),
              const SizedBox(height: 3),
              Text(
                widget.label,
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.82)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dot grid background painter ─────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.032)
      ..style = PaintingStyle.fill;
    const spacing = 24.0;
    const radius = 1.5;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── Data ─────────────────────────────────────────────────
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
  final String tagEmoji;
  final String tagLabel;

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
    required this.tagEmoji,
    required this.tagLabel,
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

// ═══════════════════════════════════════════════════════════
//  Animal Painters — all fully detailed
// ═══════════════════════════════════════════════════════════

class _BearPainter extends CustomPainter {
  final Color color;
  const _BearPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final dark = Paint()..color = color.withOpacity(0.50);
    final white = Paint()..color = Colors.white.withOpacity(0.92);
    final black = Paint()..color = const Color(0xFF1A1A1A);
    final nose = Paint()..color = const Color(0xFF3A1A1A);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.34;

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
        dark);

    // Eyes (white + pupil + shine)
    canvas.drawCircle(Offset(cx - r * 0.34, cy - r * 0.14), r * 0.16, white);
    canvas.drawCircle(Offset(cx + r * 0.34, cy - r * 0.14), r * 0.16, white);
    canvas.drawCircle(Offset(cx - r * 0.32, cy - r * 0.12), r * 0.095, black);
    canvas.drawCircle(Offset(cx + r * 0.32, cy - r * 0.12), r * 0.095, black);
    // Eye shine
    canvas.drawCircle(Offset(cx - r * 0.26, cy - r * 0.20), r * 0.040, white);
    canvas.drawCircle(Offset(cx + r * 0.38, cy - r * 0.20), r * 0.040, white);

    // Nose
    final nosePath = Path()
      ..moveTo(cx, cy + r * 0.20)
      ..lineTo(cx - r * 0.12, cy + r * 0.06)
      ..lineTo(cx + r * 0.12, cy + r * 0.06)
      ..close();
    canvas.drawPath(nosePath, nose);

    // Smile
    final smilePaint = Paint()
      ..color = nose.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(cx - r * 0.18, cy + r * 0.26)
      ..quadraticBezierTo(cx, cy + r * 0.40, cx + r * 0.18, cy + r * 0.26);
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant _BearPainter old) => old.color != color;
}

class _DuckPainter extends CustomPainter {
  final Color color;
  const _DuckPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final white = Paint()..color = Colors.white.withOpacity(0.92);
    final black = Paint()..color = const Color(0xFF1A1A1A);
    final orange = Paint()..color = const Color(0xFFFF8C00);
    final darkOrange = Paint()..color = const Color(0xFFCC6600);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.30;

    // Body
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + r * 0.55), width: r * 1.6, height: r * 1.2), p);

    // Head
    canvas.drawCircle(Offset(cx, cy - r * 0.08), r, p);

    // Wing highlight
    final wingPaint = Paint()..color = color.withOpacity(0.60);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - r * 0.20, cy + r * 0.70), width: r * 0.70, height: r * 0.38),
        wingPaint);

    // Beak (upper + lower)
    final upperBeak = Path()
      ..moveTo(cx + r * 0.82, cy - r * 0.08)
      ..lineTo(cx + r * 1.28, cy)
      ..lineTo(cx + r * 0.82, cy + r * 0.12)
      ..close();
    canvas.drawPath(upperBeak, orange);

    final lowerBeak = Path()
      ..moveTo(cx + r * 0.82, cy + r * 0.10)
      ..lineTo(cx + r * 1.20, cy + r * 0.16)
      ..lineTo(cx + r * 0.82, cy + r * 0.24)
      ..close();
    canvas.drawPath(lowerBeak, darkOrange);

    // Eye white + pupil + shine
    canvas.drawCircle(Offset(cx + r * 0.30, cy - r * 0.22), r * 0.17, white);
    canvas.drawCircle(Offset(cx + r * 0.32, cy - r * 0.20), r * 0.10, black);
    canvas.drawCircle(Offset(cx + r * 0.26, cy - r * 0.26), r * 0.040, white);

    // Cheek blush
    final blush = Paint()..color = Colors.pink.withOpacity(0.30);
    canvas.drawCircle(Offset(cx + r * 0.06, cy + r * 0.06), r * 0.16, blush);
  }

  @override
  bool shouldRepaint(covariant _DuckPainter old) => old.color != color;
}

class _CatPainter extends CustomPainter {
  final Color color;
  const _CatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final dark = Paint()..color = color.withOpacity(0.55);
    final white = Paint()..color = Colors.white.withOpacity(0.92);
    final black = Paint()..color = const Color(0xFF1A1A1A);
    final pink = Paint()..color = const Color(0xFFFFB3C6);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.32;

    // Ears (triangles)
    final leftEar = Path()
      ..moveTo(cx - r * 0.80, cy - r * 0.50)
      ..lineTo(cx - r * 0.38, cy - r * 1.05)
      ..lineTo(cx - r * 0.10, cy - r * 0.68)
      ..close();
    canvas.drawPath(leftEar, p);

    final rightEar = Path()
      ..moveTo(cx + r * 0.80, cy - r * 0.50)
      ..lineTo(cx + r * 0.38, cy - r * 1.05)
      ..lineTo(cx + r * 0.10, cy - r * 0.68)
      ..close();
    canvas.drawPath(rightEar, p);

    // Inner ears (pink)
    final leftInner = Path()
      ..moveTo(cx - r * 0.70, cy - r * 0.55)
      ..lineTo(cx - r * 0.38, cy - r * 0.94)
      ..lineTo(cx - r * 0.14, cy - r * 0.66)
      ..close();
    canvas.drawPath(leftInner, pink);

    final rightInner = Path()
      ..moveTo(cx + r * 0.70, cy - r * 0.55)
      ..lineTo(cx + r * 0.38, cy - r * 0.94)
      ..lineTo(cx + r * 0.14, cy - r * 0.66)
      ..close();
    canvas.drawPath(rightInner, pink);

    // Head
    canvas.drawCircle(Offset(cx, cy), r, p);

    // Muzzle
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + r * 0.30), width: r * 0.80, height: r * 0.48),
        dark);

    // Eyes (cat-like, slightly oval)
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - r * 0.34, cy - r * 0.14), width: r * 0.32, height: r * 0.26),
        white);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + r * 0.34, cy - r * 0.14), width: r * 0.32, height: r * 0.26),
        white);

    // Pupils (vertical slits)
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - r * 0.34, cy - r * 0.14), width: r * 0.10, height: r * 0.22),
        black);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + r * 0.34, cy - r * 0.14), width: r * 0.10, height: r * 0.22),
        black);

    // Eye shine
    canvas.drawCircle(Offset(cx - r * 0.28, cy - r * 0.20), r * 0.040, white);
    canvas.drawCircle(Offset(cx + r * 0.40, cy - r * 0.20), r * 0.040, white);

    // Nose (small triangle)
    final nosePath = Path()
      ..moveTo(cx, cy + r * 0.16)
      ..lineTo(cx - r * 0.09, cy + r * 0.06)
      ..lineTo(cx + r * 0.09, cy + r * 0.06)
      ..close();
    canvas.drawPath(nosePath, pink);

    // Whiskers
    final whiskerPaint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..strokeWidth = r * 0.045
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left whiskers
    canvas.drawLine(Offset(cx - r * 0.24, cy + r * 0.18), Offset(cx - r * 0.82, cy + r * 0.10), whiskerPaint);
    canvas.drawLine(Offset(cx - r * 0.24, cy + r * 0.22), Offset(cx - r * 0.82, cy + r * 0.28), whiskerPaint);
    // Right whiskers
    canvas.drawLine(Offset(cx + r * 0.24, cy + r * 0.18), Offset(cx + r * 0.82, cy + r * 0.10), whiskerPaint);
    canvas.drawLine(Offset(cx + r * 0.24, cy + r * 0.22), Offset(cx + r * 0.82, cy + r * 0.28), whiskerPaint);

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF3A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(cx - r * 0.14, cy + r * 0.28)
      ..quadraticBezierTo(cx, cy + r * 0.40, cx + r * 0.14, cy + r * 0.28);
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant _CatPainter old) => old.color != color;
}

class _BunnyPainter extends CustomPainter {
  final Color color;
  const _BunnyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final white = Paint()..color = Colors.white.withOpacity(0.92);
    final black = Paint()..color = const Color(0xFF1A1A1A);
    final pink = Paint()..color = const Color(0xFFFFB3C6);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.30;

    // Long ears
    final leftEarOuter = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - r * 0.44, cy - r * 1.10), width: r * 0.44, height: r * 1.0),
        Radius.circular(r * 0.22));
    canvas.drawRRect(leftEarOuter, p);

    final rightEarOuter = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + r * 0.44, cy - r * 1.10), width: r * 0.44, height: r * 1.0),
        Radius.circular(r * 0.22));
    canvas.drawRRect(rightEarOuter, p);

    // Inner ear (pink)
    final leftEarInner = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - r * 0.44, cy - r * 1.10), width: r * 0.22, height: r * 0.70),
        Radius.circular(r * 0.11));
    canvas.drawRRect(leftEarInner, pink);

    final rightEarInner = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + r * 0.44, cy - r * 1.10), width: r * 0.22, height: r * 0.70),
        Radius.circular(r * 0.11));
    canvas.drawRRect(rightEarInner, pink);

    // Head
    canvas.drawCircle(Offset(cx, cy), r, p);

    // Chubby cheeks
    final blush = Paint()..color = Colors.pink.withOpacity(0.28);
    canvas.drawCircle(Offset(cx - r * 0.44, cy + r * 0.18), r * 0.20, blush);
    canvas.drawCircle(Offset(cx + r * 0.44, cy + r * 0.18), r * 0.20, blush);

    // Eyes (big round)
    canvas.drawCircle(Offset(cx - r * 0.32, cy - r * 0.12), r * 0.18, white);
    canvas.drawCircle(Offset(cx + r * 0.32, cy - r * 0.12), r * 0.18, white);
    canvas.drawCircle(Offset(cx - r * 0.30, cy - r * 0.10), r * 0.11, black);
    canvas.drawCircle(Offset(cx + r * 0.30, cy - r * 0.10), r * 0.11, black);
    // Shine
    canvas.drawCircle(Offset(cx - r * 0.24, cy - r * 0.16), r * 0.04, white);
    canvas.drawCircle(Offset(cx + r * 0.36, cy - r * 0.16), r * 0.04, white);

    // Nose (pink circle)
    canvas.drawCircle(Offset(cx, cy + r * 0.10), r * 0.085, pink);

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF3A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(cx - r * 0.16, cy + r * 0.25)
      ..quadraticBezierTo(cx, cy + r * 0.38, cx + r * 0.16, cy + r * 0.25);
    canvas.drawPath(smilePath, smilePaint);

    // Little teeth
    final teethPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final leftTooth = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - r * 0.12, cy + r * 0.21, r * 0.11, r * 0.12),
        Radius.circular(r * 0.03));
    canvas.drawRRect(leftTooth, teethPaint);
    final rightTooth = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + r * 0.01, cy + r * 0.21, r * 0.11, r * 0.12),
        Radius.circular(r * 0.03));
    canvas.drawRRect(rightTooth, teethPaint);
  }

  @override
  bool shouldRepaint(covariant _BunnyPainter old) => old.color != color;
}