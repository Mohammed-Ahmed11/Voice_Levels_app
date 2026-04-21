import 'dart:math';
import 'package:flutter/material.dart';
import 'package:voice_levels_app/l10n/app_localizations.dart';
import '../routes.dart';
import '../services/local_db.dart';
import '../models/parent_profile.dart';

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

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _cardControllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      ),
    );

    _cardFades = _cardControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _cardSlides = _cardControllers
        .map(
          (c) => Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
              .animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)),
        )
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

  // الكروت بتتبنى جوه build() عشان AppLocalizations محتاجة context
  List<_CardData> _buildCards(BuildContext context) => [
        _CardData(
          heroTag: 'hero_start',
          emoji: '🎙️',
          title: AppLocalizations.of(context)!.cardStartTitle,
          subtitle: AppLocalizations.of(context)!.cardStartSubtitle,
          bgColor: const Color(0xFFFF6B6B),
          accentColor: const Color(0xFFFF8E8E),
          shadowColor: const Color(0xFFD94F4F),
          stars: const [Color(0xFFFFD93D), Color(0xFFFFE98A)],
          route: AppRoutes.modeSelect,
        ),
        _CardData(
          heroTag: 'hero_recordings',
          emoji: '🎵',
          title: AppLocalizations.of(context)!.cardReportsTitle,
          subtitle: AppLocalizations.of(context)!.cardReportsSubtitle,
          bgColor: const Color(0xFF6BCB77),
          accentColor: const Color(0xFF8EDA99),
          shadowColor: const Color(0xFF4DA85A),
          stars: const [Color(0xFFFFD93D), Color(0xFFFFA500)],
          route: AppRoutes.recordings,
        ),
        _CardData(
          heroTag: 'hero_profile',
          emoji: '👶',
          title: AppLocalizations.of(context)!.cardProfilesTitle,
          subtitle: AppLocalizations.of(context)!.cardProfilesSubtitle,
          bgColor: const Color(0xFF4D96FF),
          accentColor: const Color(0xFF7AB3FF),
          shadowColor: const Color(0xFF2B72D9),
          stars: const [Color(0xFFFF6B9D), Color(0xFFFF9DC8)],
          route: AppRoutes.profile,
        ),
        _CardData(
          heroTag: 'hero_settings',
          emoji: '⚙️',
          title: AppLocalizations.of(context)!.cardOptionsTitle,
          subtitle: AppLocalizations.of(context)!.cardOptionsSubtitle,
          bgColor: const Color(0xFFFF9F1C),
          accentColor: const Color(0xFFFFBB5C),
          shadowColor: const Color(0xFFD97F00),
          stars: const [Color(0xFF6BCB77), Color(0xFFA8EDBB)],
          route: AppRoutes.settings,
        ),
      ];

  Future<String?> _pickProfileId() async {
    final profiles = LocalDb.getProfiles();

    if (profiles.isEmpty) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFFF6B6B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            AppLocalizations.of(context)!.snackbarCreateProfileFirst,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      );
      Navigator.pushNamed(context, AppRoutes.profile);
      return null;
    }

    final activeId = LocalDb.getActiveProfileId();
    ParentProfile? active =
        profiles.where((p) => p.id == activeId).isNotEmpty
            ? profiles.firstWhere((p) => p.id == activeId)
            : null;

    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFFFF4E8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(dialogContext)!.profilePickerTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3D3D3D),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(dialogContext)!.profilePickerSubtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),

                if (active != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6BCB77).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFF6BCB77).withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${AppLocalizations.of(dialogContext)!.profilePickerActivePrefix}${active.displayName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3D3D3D),
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: profiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (listContext, i) {
                      final p = profiles[i];
                      final isActive = p.id == activeId;
                      return GestureDetector(
                        onTap: () => Navigator.pop(dialogContext, p.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF6BCB77)
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9C8AE6)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text('👶',
                                      style: TextStyle(fontSize: 18)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.displayName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF3D3D3D),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p.phone.isEmpty
                                          ? AppLocalizations.of(listContext)!.profilePickerNoPhone
                                          : p.phone,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isActive)
                                const Text('✅',
                                    style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          Navigator.pushNamed(context, AppRoutes.profile);
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4D96FF),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF2B72D9),
                                blurRadius: 0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(dialogContext)!.profilePickerNewProfileBtn,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogContext, null),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E0D5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(dialogContext)!.profilePickerCancelBtn,
                              style: const TextStyle(
                                color: Color(0xFF3D3D3D),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCardTap(_CardData card) async {
    if (card.route == AppRoutes.modeSelect) {
      final profileId = await _pickProfileId();
      if (profileId == null) return;

      await LocalDb.setActiveProfileId(profileId);

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.modeSelect,
        arguments: {'profileId': profileId, 'heroTag': card.heroTag},
      );
      return;
    }

    Navigator.pushNamed(
      context,
      card.route,
      arguments: {'heroTag': card.heroTag},
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = _buildCards(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 900 ? 3 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Stack(
        children: [
          Positioned(
              top: -60,
              left: -40,
              child: _Blob(color: const Color(0xFFFFD6D6), size: 220)),
          Positioned(
              top: 80,
              right: -50,
              child: _Blob(color: const Color(0xFFD6F0FF), size: 190)),
          Positioned(
              bottom: 100,
              left: -30,
              child: _Blob(color: const Color(0xFFD6FFE4), size: 200)),
          Positioned(
              bottom: -40,
              right: 20,
              child: _Blob(color: const Color(0xFFFFEDD6), size: 170)),

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

                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, sin(_floatController.value * pi) * 6),
                      child: child,
                    ),
                    child: SizedBox(
                      height: 72,
                      child: Image.asset(
                        'assets/images/applogo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const _FallbackLogo(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)!.homeGreeting,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3D3D3D),
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.homeGreetingName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.homeSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.92,
                      ),
                      itemCount: cards.length,
                      itemBuilder: (context, i) {
                        return FadeTransition(
                          opacity: _cardFades[i],
                          child: SlideTransition(
                            position: _cardSlides[i],
                            child: _KidsCard(
                              data: cards[i],
                              floatController: _floatController,
                              floatPhaseOffset: i * 0.25,
                              onTap: () => _handleCardTap(cards[i]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
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
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.homeTip,
                          style: const TextStyle(
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

// ══════════════════════════════════════════════════════════════
// الكلاسات الثانوية — بدون تغيير
// ══════════════════════════════════════════════════════════════

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

class _KidsCardState extends State<_KidsCard>
    with SingleTickerProviderStateMixin {
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
          final phase =
              (widget.floatController.value + widget.floatPhaseOffset) % 1.0;
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
                BoxShadow(
                  color: widget.data.shadowColor,
                  blurRadius: 0,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: widget.data.shadowColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28)),
                    child: CustomPaint(
                      size: const Size(double.infinity, 56),
                      painter: _WavePainter(widget.data.accentColor),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: _Sparkle(colors: widget.data.stars),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

  const _Dot({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
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
      children: [
        const Text('🍼', style: TextStyle(fontSize: 30)),
        const SizedBox(width: 8),
        Text(
          AppLocalizations.of(context)!.fallbackLogoAppName,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFF6B6B),
          ),
        ),
      ],
    );
  }
}