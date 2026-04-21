import 'dart:math';
import 'package:flutter/material.dart';
import '../models/parent_profile.dart';
import 'package:voice_levels_app/l10n/app_localizations.dart';
import '../routes.dart';
import '../services/local_db.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _child = TextEditingController();
  final _notes = TextEditingController();

  late final AnimationController _bgFloat1;
  late final AnimationController _bgFloat2;
  late final AnimationController _saveCtrl;
  late final Animation<double> _saveScale;

  bool _saved = false;

  List<ParentProfile> _profiles = [];
  String? _selectedId; // ✅ current patient

  @override
  void initState() {
    super.initState();

    _bgFloat1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _bgFloat2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _saveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _saveScale = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _saveCtrl, curve: Curves.easeOut));

    _loadProfiles();
  }

  void _loadProfiles() {
    final profiles = LocalDb.getProfiles();
    final activeId = LocalDb.getActiveProfileId();

    setState(() {
      _profiles = profiles;
      _selectedId =
          activeId ?? (profiles.isNotEmpty ? profiles.first.id : null);
    });

    if (_selectedId != null) {
      final p = _profiles.firstWhere(
        (e) => e.id == _selectedId,
        orElse: () => _profiles.first,
      );
      _fillForm(p);
    }
  }

  void _fillForm(ParentProfile p) {
    _name.text = p.parentName;
    _phone.text = p.phone;
    _child.text = p.childName;
    _notes.text = p.notes;
  }

  void _clearForm() {
    _name.clear();
    _phone.clear();
    _child.clear();
    _notes.clear();
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _selectProfile(String id) async {
    final p = _profiles.firstWhere((e) => e.id == id);
    setState(() => _selectedId = id);
    _fillForm(p);
    await LocalDb.setActiveProfileId(id);
  }

  Future<void> _addNewProfile() async {
    setState(() => _selectedId = null);
    _clearForm();
    _child.text = 'Patient ${_profiles.length + 1}';
  }

  Future<void> _save() async {
    await _saveCtrl.forward();
    await _saveCtrl.reverse();

    final id = _selectedId ?? _newId();

    final profile = ParentProfile(
      id: id,
      parentName: _name.text.trim(),
      phone: _phone.text.trim(),
      childName: _child.text.trim(),
      notes: _notes.text.trim(),
    );

    await LocalDb.upsertProfile(profile);
    await LocalDb.setActiveProfileId(id);

    setState(() {
      _saved = true;
      _selectedId = id;
      _profiles = LocalDb.getProfiles();
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  Future<void> _confirmDeleteCurrent() async {
    final id = _selectedId;
    if (id == null) return;

    final p = _profiles.firstWhere(
      (e) => e.id == id,
      orElse: () => _profiles.first,
    );

    final t = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFF4E8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗑️', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 10),
              Text(
                'Delete "${p.childName.isEmpty ? 'Patient' : p.childName}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D3D3D),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.profileDeleteBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E0D5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            t.profileDeleteCancel,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3D3D3D),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFCC3333),
                              blurRadius: 0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child:  Center(
                          child: Text(
                            t.profileDeleteConfirm,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
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
      ),
    );

    // if (ok == true) {
    //   await LocalDb.deleteProfile(id);
    //   _loadProfiles();
    // }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _child.dispose();
    _notes.dispose();
    _bgFloat1.dispose();
    _bgFloat2.dispose();
    _saveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E8),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: -70,
            left: -50,
            child: _Blob(color: const Color(0xFFD6ECFF), size: 250),
          ),
          Positioned(
            top: 80,
            right: -60,
            child: _Blob(color: const Color(0xFFFFDFDF), size: 200),
          ),
          Positioned(
            bottom: 140,
            left: -50,
            child: _Blob(color: const Color(0xFFD6FFE4), size: 210),
          ),
          Positioned(
            bottom: -50,
            right: 0,
            child: _Blob(color: const Color(0xFFFFF0C8), size: 180),
          ),

          AnimatedBuilder(
            animation: _bgFloat1,
            builder: (_, __) => Positioned(
              top: 100 + sin(_bgFloat1.value * pi) * 10,
              right: -22,
              child: Opacity(
                opacity: 0.13,
                child: Transform.rotate(
                  angle: 0.20,
                  child: CustomPaint(
                    size: const Size(100, 100),
                    painter: const _BearPainter(color: Color(0xFF4D96FF)),
                  ),
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
                  child: CustomPaint(
                    size: const Size(90, 90),
                    painter: const _BunnyPainter(color: Color(0xFF6BCB77)),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
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
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: Color(0xFF3D3D3D),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const SizedBox(width: 10),
                      Text(
                        t.profileTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF9C8AE6),
                        ),
                      ),
                      const Spacer(),
                      if (_selectedId != null)
                        GestureDetector(
                          onTap: _confirmDeleteCurrent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              '🗑️',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    t.profileSubtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ✅ Profiles bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final p in _profiles) ...[
                                _ProfileChip(
                                  label: (p.childName.trim().isEmpty
                                      ? 'Patient'
                                      : p.childName.trim()),
                                  selected: p.id == _selectedId,
                                  onTap: () => _selectProfile(p.id),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _addNewProfile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C8AE6),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF6D5CC7),
                                blurRadius: 0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            '➕',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    children: [
                      _SectionLabel(
                        emoji: '👨‍👩‍👧',
                        label: t.profileParentSection,
                      ),
                      const SizedBox(height: 10),
                      _KidsField(
                        controller: _name,
                        label: t.profileParentName,
                        emoji: '🏷️',
                        hint: t.profileParentNameHint,
                        color: const Color(0xFF4D96FF),
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 12),
                      _KidsField(
                        controller: _phone,
                        label: t.profilePhone,
                        emoji: '📞',
                        hint: t.profilePhoneHint,
                        color: const Color(0xFF6BCB77),
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 22),

                      _SectionLabel(
                        emoji: '👶',
                        label: t.profilePatientSection,
                      ),
                      const SizedBox(height: 10),
                      _KidsField(
                        controller: _child,
                        label: t.profilePatientName,
                        emoji: '🌟',
                        hint: t.profilePatientNameHint,
                        color: const Color(0xFFFF9F1C),
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 12),
                      _KidsField(
                        controller: _notes,
                        label: t.profileNotes,
                        emoji: '📝',
                        hint: t.profileNotesHint,
                        color: const Color(0xFFB66DFF),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),

                      AnimatedBuilder(
                        animation: _saveScale,
                        builder: (_, child) => Transform.scale(
                          scale: _saveScale.value,
                          child: child,
                        ),
                        child: GestureDetector(
                          onTapDown: (_) => _saveCtrl.forward(),
                          onTapUp: (_) {
                            _saveCtrl.reverse();
                            _save();
                          },
                          onTapCancel: () => _saveCtrl.reverse(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 58,
                            decoration: BoxDecoration(
                              color: _saved
                                  ? const Color(0xFF6BCB77)
                                  : const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_saved
                                              ? const Color(0xFF3A9947)
                                              : const Color(0xFFCC3333))
                                          .withOpacity(0.55),
                                  blurRadius: 0,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color:
                                      (_saved
                                              ? const Color(0xFF3A9947)
                                              : const Color(0xFFCC3333))
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
                                  _saved
                                      ? t.profileSaved
                                      : (_selectedId == null
                                            ? t.profileCreate
                                            : t.profileSave),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
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

// ───────────────────────── UI helpers ─────────────────────────

class _ProfileChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF9C8AE6) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF9C8AE6) : const Color(0xFFE8E0D5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF9C8AE6).withOpacity(0.25)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: selected ? Colors.white : const Color(0xFF3D3D3D),
          ),
        ),
      ),
    );
  }
}

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
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
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
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
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
            _NavItem(
              emoji: '🏠',
              label: 'Home',
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                screenContext,
                AppRoutes.home,
                (r) => false,
              ),
            ),
            _NavItem(
              emoji: '🎵',
              label: 'Records',
              onTap: () =>
                  Navigator.pushNamed(screenContext, AppRoutes.recordings),
            ),
            _NavItem(
              emoji: '⚙️',
              label: 'Options',
              onTap: () =>
                  Navigator.pushNamed(screenContext, AppRoutes.settings),
            ),
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
  const _NavItem({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

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
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            color: _pressed
                ? Colors.white.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 3),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BearPainter extends CustomPainter {
  final Color color;
  const _BearPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.55),
      size.width * 0.34,
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _BearPainter old) => old.color != color;
}

class _BunnyPainter extends CustomPainter {
  final Color color;
  const _BunnyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.55),
      size.width * 0.30,
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _BunnyPainter old) => old.color != color;
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
