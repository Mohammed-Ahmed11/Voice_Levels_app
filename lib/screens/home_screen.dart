import 'dart:math';
import 'package:flutter/material.dart';
import '../routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final List<AnimationController> _cardControllers;
  late final List<Animation<double>> _cardFades;
  late final List<Animation<Offset>> _cardSlides;

  final List<_CardData> _cards = const [
    _CardData(
      heroTag: 'hero_start',
      emoji: '🎙️',
      title: 'Start',
      subtitle: 'Record something fun!',
      bgColor: Color(0xFFFF6B6B),
      accentColor: Color(0xFFFF8E8E),
      shadowColor: Color(0xFFD94F4F),
      stars: [Color(0xFFFFD93D), Color(0xFFFFE98A)],
      route: AppRoutes.modeSelect,
    ),
    _CardData(
      heroTag: 'hero_recordings',
      emoji: '🎵',
      title: 'Recordings',
      subtitle: 'Listen & share!',
      bgColor: Color(0xFF6BCB77),
      accentColor: Color(0xFF8EDA99),
      shadowColor: Color(0xFF4DA85A),
      stars: [Color(0xFFFFD93D), Color(0xFFFFA500)],
      route: AppRoutes.recordings,
    ),
    _CardData(
      heroTag: 'hero_profile',
      emoji: '👶',
      title: 'Profile',
      subtitle: 'Parent info',
      bgColor: Color(0xFF4D96FF),
      accentColor: Color(0xFF7AB3FF),
      shadowColor: Color(0xFF2B72D9),
      stars: [Color(0xFFFF6B9D), Color(0xFFFF9DC8)],
      route: AppRoutes.profile,
    ),
    _CardData(
      heroTag: 'hero_settings',
      emoji: '⚙️',
      title: 'Options',
      subtitle: 'App settings',
      bgColor: Color(0xFFFF9F1C),
      accentColor: Color(0xFFFFBB5C),
      shadowColor: Color(0xFFD97F00),
      stars: [Color(0xFF6BCB77), Color(0xFFA8EDBB)],
      route: AppRoutes.settings,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _cardControllers = List.generate(
      _cards.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      ),
    );

    _cardFades = _cardControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _cardSlides = _cardControllers
        .map((c) => Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)))
        .toList();

    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + i * 120), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    for (final c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 900 ? 3 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Stack(
        children: [
          // Soft pastel blobs
          Positioned(top: -60, left: -40, child: _Blob(color: const Color(0xFFFFD6D6), size: 220)),
          Positioned(top: 80, right: -50, child: _Blob(color: const Color(0xFFD6F0FF), size: 190)),
          Positioned(bottom: 100, left: -30, child: _Blob(color: const Color(0xFFD6FFE4), size: 200)),
          Positioned(bottom: -40, right: 20, child: _Blob(color: const Color(0xFFFFEDD6), size: 170)),

          // Floating dot accents
          const _Dot(top: 160, left: 28, color: Color(0xFFFF6B6B), size: 10),
          const _Dot(top: 220, right: 22, color: Color(0xFF6BCB77), size: 8),
          const _Dot(top: 340, left: 14, color: Color(0xFF4D96FF), size: 12),
          const _Dot(bottom: 220, left: 18, color: Color(0xFFFF9F1C), size: 9),
          const _Dot(bottom: 160, right: 16, color: Color(0xFFFF6B6B), size: 7),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Floating logo
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, sin(_floatController.value * pi) * 6),
                      child: child,
                    ),
                    child: SizedBox(
                      height: 80,
                      child: Image.asset(
                        'assets/images/applogo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const _FallbackLogo(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Greeting header
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hello, ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3D3D3D),
                          ),
                        ),
                        TextSpan(
                          text: 'Little Star! ⭐',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF9C8AE6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'What do you want to do today?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Cards grid
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.92,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, i) {
                        return FadeTransition(
                          opacity: _cardFades[i],
                          child: SlideTransition(
                            position: _cardSlides[i],
                            child: _KidsCard(
                              data: _cards[i],
                              floatController: _floatController,
                              floatPhaseOffset: i * 0.25,
                              onTap: () => Navigator.pushNamed(
                                context,
                                _cards[i].route,
                                arguments: {'heroTag': _cards[i].heroTag},
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tip pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD93D),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD93D).withOpacity(0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('💡', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 8),
                        Text(
                          'Set Max Level & Countdown in Options!',
                          style: TextStyle(
                            color: Color(0xFF5A4000),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Kids Card ────────────────────────────────────────────────────────────────

class _KidsCard extends StatefulWidget {
  final _CardData data;
  final AnimationController floatController;
  final double floatPhaseOffset;
  final VoidCallback onTap;

  const _KidsCard({
    required this.data,
    required this.floatController,
    required this.floatPhaseOffset,
    required this.onTap,
  });

  @override
  State<_KidsCard> createState() => _KidsCardState();
}

class _KidsCardState extends State<_KidsCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
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
        animation: Listenable.merge([_pressCtrl, widget.floatController]),
        builder: (_, child) {
          final phase = (widget.floatController.value + widget.floatPhaseOffset) % 1.0;
          final dy = sin(phase * pi) * 4;
          return Transform.translate(
            offset: Offset(0, dy),
            child: Transform.scale(scale: _scaleAnim.value, child: child),
          );
        },
        child: Hero(
          tag: widget.data.heroTag,
          child: Container(
            decoration: BoxDecoration(
              color: widget.data.bgColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                // Solid cartoon bottom shadow
                BoxShadow(
                  color: widget.data.shadowColor,
                  blurRadius: 0,
                  offset: const Offset(0, 6),
                ),
                // Soft ambient glow
                BoxShadow(
                  color: widget.data.shadowColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Wavy top accent strip
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: CustomPaint(
                      size: const Size(double.infinity, 56),
                      painter: _WavePainter(widget.data.accentColor),
                    ),
                  ),
                ),

                // Star sparkles (top right)
                Positioned(
                  top: 10,
                  right: 12,
                  child: _Sparkle(colors: widget.data.stars),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji bubble
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 2.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.data.emoji,
                            style: const TextStyle(fontSize: 27),
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        widget.data.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.data.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

// ─── Wave Painter ─────────────────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  final Color color;
  const _WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 28)
      ..quadraticBezierTo(size.width * 0.75, 52, size.width * 0.5, 38)
      ..quadraticBezierTo(size.width * 0.25, 22, 0, 48)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Sparkle ──────────────────────────────────────────────────────────────────

class _Sparkle extends StatelessWidget {
  final List<Color> colors;
  const _Sparkle({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Icon(Icons.star_rounded, color: colors[0], size: 12),
            const SizedBox(width: 2),
            Icon(Icons.star_rounded, color: colors[1], size: 8),
          ],
        ),
        const SizedBox(height: 2),
        Icon(Icons.star_rounded, color: colors[0], size: 10),
      ],
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

class _CardData {
  final String heroTag;
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color accentColor;
  final Color shadowColor;
  final List<Color> stars;
  final String route;

  const _CardData({
    required this.heroTag,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.accentColor,
    required this.shadowColor,
    required this.stars,
    required this.route,
  });
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Dot extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final Color color;
  final double size;

  const _Dot({this.top, this.bottom, this.left, this.right, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text('🍼', style: TextStyle(fontSize: 30)),
        SizedBox(width: 8),
        Text(
          'BabyVoice',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFF6B6B),
          ),
        ),
      ],
    );
  }
}