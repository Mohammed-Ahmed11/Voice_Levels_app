import 'dart:math';
import 'package:flutter/material.dart';
import '../models/parent_profile.dart';
import '../routes.dart';
import '../services/local_db.dart';

// ═══════════════════════════════════════════════════════════
//  ProfileScreen — Kids Playful UI
// ═══════════════════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _name  = TextEditingController();
  final _phone = TextEditingController();
  final _child = TextEditingController();
  final _notes = TextEditingController();

  late final AnimationController _floatCtrl;
  late final AnimationController _bgFloat1;
  late final AnimationController _bgFloat2;
  late final AnimationController _saveCtrl;
  late final Animation<double> _saveScale;

  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final p = LocalDb.getProfile();
    if (p != null) {
      _name.text  = p.parentName;
      _phone.text = p.phone;
      _child.text = p.childName;
      _notes.text = p.notes;
    }

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _bgFloat1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
    _bgFloat2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);

    _saveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _saveScale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _saveCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _child.dispose();
    _notes.dispose();
    _floatCtrl.dispose();
    _bgFloat1.dispose();
    _bgFloat2.dispose();
    _saveCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _saveCtrl.forward();
    await _saveCtrl.reverse();

    final profile = ParentProfile(
      parentName: _name.text.trim(),
      phone:      _phone.text.trim(),
      childName:  _child.text.trim(),
      notes:      _notes.text.trim(),
    );
    await LocalDb.saveProfile(profile);

    setState(() => _saved = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E8),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Pastel blobs ──
          Positioned(top: -70, left: -50,  child: _Blob(color: const Color(0xFFD6ECFF), size: 250)),
          Positioned(top: 80,  right: -60, child: _Blob(color: const Color(0xFFFFDFDF), size: 200)),
          Positioned(bottom: 140, left: -50, child: _Blob(color: const Color(0xFFD6FFE4), size: 210)),
          Positioned(bottom: -50, right: 0,  child: _Blob(color: const Color(0xFFFFF0C8), size: 180)),

          // ── Floating bg animals ──
          AnimatedBuilder(
            animation: _bgFloat1,
            builder: (_, __) => Positioned(
              top: 100 + sin(_bgFloat1.value * pi) * 10,
              right: -22,
              child: Opacity(
                opacity: 0.13,
                child: Transform.rotate(
                  angle: 0.20,
                  child: CustomPaint(size: const Size(100, 100), painter: const _BearPainter(color: Color(0xFF4D96FF))),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _bgFloat2,
            builder: (_, __) => Positioned(
              bottom: 160 + sin(_bgFloat2.value * pi) * 9,
              left: -20,
              child: Opacity(
                opacity: 0.12,
                child: Transform.rotate(
                  angle: -0.18,
                  child: CustomPaint(size: const Size(90, 90), painter: const _BunnyPainter(color: Color(0xFF6BCB77))),
                ),
              ),
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: Column(
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
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12, offset: const Offset(0, 4),
                            )],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: Color(0xFF3D3D3D)),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Floating mascot + title
                      // AnimatedBuilder(
                      //   animation: _floatCtrl,
                      //   builder: (_, child) => Transform.translate(
                      //     offset: Offset(0, sin(_floatCtrl.value * pi) * 5),
                      //     child: child,
                      //   ),
                      //   child: CustomPaint(
                      //     size: const Size(46, 46),
                      //     painter: const _BearPainter(color: Color(0xFFFF6B6B)),
                      //   ),
                      // ),
                      const SizedBox(width: 10),
                      RichText(
                        text: const TextSpan(children: [
                          TextSpan(
                            text: 'My ',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF3D3D3D)),
                          ),
                          TextSpan(
                            text: 'Profile',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF9C8AE6)),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Tell us about you & your little one 🍼',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 18),

                // Form
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    children: [
                      // ── Parent section ──
                      _SectionLabel(emoji: '👨‍👩‍👧', label: 'Parent Info'),
                      const SizedBox(height: 10),
                      _KidsField(
                        controller: _name,
                        label: 'Parent Name',
                        emoji: '🏷️',
                        hint: 'e.g. Sarah',
                        color: const Color(0xFF4D96FF),
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 12),
                      _KidsField(
                        controller: _phone,
                        label: 'Phone Number',
                        emoji: '📞',
                        hint: 'e.g. +1 555 0123',
                        color: const Color(0xFF6BCB77),
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 22),

                      // ── Child section ──
                      _SectionLabel(emoji: '👶', label: 'Child Info'),
                      const SizedBox(height: 10),
                      _KidsField(
                        controller: _child,
                        label: 'Child Name',
                        emoji: '🌟',
                        hint: 'e.g. Lily',
                        color: const Color(0xFFFF9F1C),
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 12),
                      _KidsField(
                        controller: _notes,
                        label: 'Notes',
                        emoji: '📝',
                        hint: 'Any extra info...',
                        color: const Color(0xFFB66DFF),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 28),

                      // ── Save button ──
                      AnimatedBuilder(
                        animation: _saveScale,
                        builder: (_, child) => Transform.scale(scale: _saveScale.value, child: child),
                        child: GestureDetector(
                          onTapDown: (_) => _saveCtrl.forward(),
                          onTapUp: (_) { _saveCtrl.reverse(); _save(); },
                          onTapCancel: () => _saveCtrl.reverse(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 58,
                            decoration: BoxDecoration(
                              color: _saved ? const Color(0xFF6BCB77) : const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: (_saved ? const Color(0xFF3A9947) : const Color(0xFFCC3333))
                                      .withOpacity(0.55),
                                  blurRadius: 0,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: (_saved ? const Color(0xFF3A9947) : const Color(0xFFCC3333))
                                      .withOpacity(0.25),
                                  blurRadius: 18,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _saved ? '✅' : '💾',
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _saved ? 'Saved!' : 'Save Profile',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                    shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

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
//  Kids-styled text field
// ═══════════════════════════════════════════════════════════

class _KidsField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String emoji;
  final String hint;
  final Color color;
  final TextInputType keyboardType;
  final int maxLines;

  const _KidsField({
    required this.controller,
    required this.label,
    required this.emoji,
    required this.hint,
    required this.color,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  State<_KidsField> createState() => _KidsFieldState();
}

class _KidsFieldState extends State<_KidsField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _focused
                ? widget.color.withOpacity(0.35)
                : Colors.black.withOpacity(0.07),
            blurRadius: _focused ? 0 : 10,
            spreadRadius: 0,
            offset: _focused ? const Offset(0, 5) : const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: _focused ? widget.color : Colors.transparent,
          width: _focused ? 2.5 : 0,
        ),
      ),
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
            labelText: widget.label,
            labelStyle: TextStyle(
              color: _focused ? widget.color : Colors.grey.shade400,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Text(widget.emoji, style: const TextStyle(fontSize: 20)),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: widget.maxLines > 1 ? 14 : 0,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Section label
// ═══════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String emoji;
  final String label;
  const _SectionLabel({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF3D3D3D),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E0D5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
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
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.85))),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Animal Painters (shared with other screens)
// ═══════════════════════════════════════════════════════════

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

    canvas.drawCircle(Offset(cx - r * 0.68, cy - r * 0.74), r * 0.36, p);
    canvas.drawCircle(Offset(cx + r * 0.68, cy - r * 0.74), r * 0.36, p);
    canvas.drawCircle(Offset(cx - r * 0.68, cy - r * 0.74), r * 0.20, dark);
    canvas.drawCircle(Offset(cx + r * 0.68, cy - r * 0.74), r * 0.20, dark);
    canvas.drawCircle(Offset(cx, cy), r, p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.34), width: r * 0.96, height: r * 0.60), dark);
    canvas.drawCircle(Offset(cx - r * 0.34, cy - r * 0.14), r * 0.15, white);
    canvas.drawCircle(Offset(cx + r * 0.34, cy - r * 0.14), r * 0.15, white);
    canvas.drawCircle(Offset(cx - r * 0.32, cy - r * 0.12), r * 0.09, black);
    canvas.drawCircle(Offset(cx + r * 0.32, cy - r * 0.12), r * 0.09, black);
    canvas.drawCircle(Offset(cx - r * 0.27, cy - r * 0.17), r * 0.04, white);
    canvas.drawCircle(Offset(cx + r * 0.37, cy - r * 0.17), r * 0.04, white);
    canvas.drawCircle(Offset(cx, cy + r * 0.18), r * 0.11, black);
    final smile = Path()
      ..moveTo(cx - r * 0.22, cy + r * 0.30)
      ..quadraticBezierTo(cx, cy + r * 0.52, cx + r * 0.22, cy + r * 0.30);
    canvas.drawPath(smile, Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.040
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(cx - r * 0.58, cy + r * 0.16), r * 0.16, Paint()..color = Colors.pink.withOpacity(0.38));
    canvas.drawCircle(Offset(cx + r * 0.58, cy + r * 0.16), r * 0.16, Paint()..color = Colors.pink.withOpacity(0.38));
  }

  @override
  bool shouldRepaint(covariant _BearPainter old) => old.color != color;
}

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

    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - r * 0.40, cy - r * 1.28), width: r * 0.46, height: r * 1.08),
      const Radius.circular(30)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + r * 0.40, cy - r * 1.28), width: r * 0.46, height: r * 1.08),
      const Radius.circular(30)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - r * 0.40, cy - r * 1.28), width: r * 0.22, height: r * 0.76),
      const Radius.circular(20)), pink);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + r * 0.40, cy - r * 1.28), width: r * 0.22, height: r * 0.76),
      const Radius.circular(20)), pink);
    canvas.drawCircle(Offset(cx, cy), r, p);
    canvas.drawCircle(Offset(cx - r * 0.52, cy + r * 0.20), r * 0.22, Paint()..color = Colors.pink.withOpacity(0.38));
    canvas.drawCircle(Offset(cx + r * 0.52, cy + r * 0.20), r * 0.22, Paint()..color = Colors.pink.withOpacity(0.38));
    canvas.drawCircle(Offset(cx - r * 0.32, cy - r * 0.10), r * 0.15, white);
    canvas.drawCircle(Offset(cx + r * 0.32, cy - r * 0.10), r * 0.15, white);
    canvas.drawCircle(Offset(cx - r * 0.30, cy - r * 0.08), r * 0.09, black);
    canvas.drawCircle(Offset(cx + r * 0.30, cy - r * 0.08), r * 0.09, black);
    canvas.drawCircle(Offset(cx - r * 0.24, cy - r * 0.14), r * 0.04, white);
    canvas.drawCircle(Offset(cx + r * 0.36, cy - r * 0.14), r * 0.04, white);
    canvas.drawCircle(Offset(cx, cy + r * 0.17), r * 0.11, pink);
    final smile = Path()
      ..moveTo(cx - r * 0.22, cy + r * 0.32)
      ..quadraticBezierTo(cx, cy + r * 0.52, cx + r * 0.22, cy + r * 0.32);
    canvas.drawPath(smile, Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.040
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(cx + r * 0.80, cy + r * 0.68), r * 0.18, white);
  }

  @override
  bool shouldRepaint(covariant _BunnyPainter old) => old.color != color;
}

// ─── Blob helper ──────────────────────────────────────────

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