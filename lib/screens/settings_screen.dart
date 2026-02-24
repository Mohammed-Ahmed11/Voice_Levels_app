import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../routes.dart';
import '../services/local_db.dart';
import '../services/permissions_service.dart';

// ═══════════════════════════════════════════════════════════
//  SettingsScreen — Kids Playful UI
// ═══════════════════════════════════════════════════════════

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AppSettings _settings;
  bool _micGranted = false;

  late final AnimationController _floatCtrl;
  late final AnimationController _bgFloat1;
  late final AnimationController _bgFloat2;

  @override
  void initState() {
    super.initState();
    _settings = LocalDb.getSettings();
    _checkMic();

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _bgFloat1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 3300))
      ..repeat(reverse: true);
    _bgFloat2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _bgFloat1.dispose();
    _bgFloat2.dispose();
    super.dispose();
  }

  Future<void> _checkMic() async {
    final ok = await PermissionsService.ensureAudioPermissions();
    if (!mounted) return;
    setState(() => _micGranted = ok);
  }

  Future<void> _save(AppSettings next) async {
    setState(() => _settings = next);
    await LocalDb.saveSettings(next);
  }

  Future<void> _resetConfirm() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: const Color(0xFFFFF4E8),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗑️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'Reset App Data?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF3D3D3D)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This will delete your profile, recordings, and all settings.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E0D5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF3D3D3D))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFCC3333), blurRadius: 0, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Center(
                          child: Text('Reset', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
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

    if (confirm != true) return;

    final items = LocalDb.getRecordings();
    for (final r in items) {
      try {
        final f = File(r.filePath);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
    }
    await LocalDb.resetAll();

    if (!mounted) return;
    setState(() {
      _settings = AppSettings.defaults();
      _micGranted = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF6BCB77),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Row(
          children: [
            Text('✅', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            Text('App data reset!', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final heroTag = (args is Map && args['heroTag'] != null)
        ? args['heroTag'].toString()
        : 'hero_settings';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E8),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Pastel blobs ──
          Positioned(top: -70,   left: -50,  child: _Blob(color: const Color(0xFFFFE4D6), size: 240)),
          Positioned(top: 100,   right: -60, child: _Blob(color: const Color(0xFFD6ECFF), size: 200)),
          Positioned(bottom: 140, left: -50, child: _Blob(color: const Color(0xFFD6FFE4), size: 200)),
          Positioned(bottom: -50, right: 0,  child: _Blob(color: const Color(0xFFFFF0C8), size: 180)),

          // ── Floating bg animals ──
          AnimatedBuilder(
            animation: _bgFloat1,
            builder: (_, __) => Positioned(
              top: 95 + sin(_bgFloat1.value * pi) * 10,
              right: -22,
              child: Opacity(
                opacity: 0.13,
                child: Transform.rotate(
                  angle: 0.18,
                  child: CustomPaint(size: const Size(100, 100), painter: const _CatPainter(color: Color(0xFFB66DFF))),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _bgFloat2,
            builder: (_, __) => Positioned(
              bottom: 170 + sin(_bgFloat2.value * pi) * 9,
              left: -20,
              child: Opacity(
                opacity: 0.12,
                child: Transform.rotate(
                  angle: -0.15,
                  child: CustomPaint(size: const Size(90, 90), painter: const _DuckPainter(color: Color(0xFFFF9F1C))),
                ),
              ),
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      Hero(
                        tag: heroTag,
                        child: GestureDetector(
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
                      ),
                      const SizedBox(width: 14),
                      // AnimatedBuilder(
                      //   animation: _floatCtrl,
                      //   builder: (_, child) => Transform.translate(
                      //     offset: Offset(0, sin(_floatCtrl.value * pi) * 5),
                      //     child: child,
                      //   ),
                      //   child: CustomPaint(
                      //     size: const Size(46, 46),
                      //     painter: const _CatPainter(color: Color(0xFFB66DFF)),
                      //   ),
                      // ),
                      const SizedBox(width: 10),
                      RichText(
                        text: const TextSpan(children: [
                          TextSpan(
                            text: 'App ',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF3D3D3D)),
                          ),
                          TextSpan(
                            text: 'Options',
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
                    'Customize how the app works ⚙️',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 18),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    children: [
                      // ── Permissions ──
                      _SectionLabel(emoji: '🎤', label: 'Permissions'),
                      const SizedBox(height: 10),
                      _SettingCard(
                        children: [
                          _MicTile(
                            granted: _micGranted,
                            onCheck: _checkMic,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Recording ──
                      _SectionLabel(emoji: '🎙️', label: 'Recording'),
                      const SizedBox(height: 10),
                      _SettingCard(
                        children: [
                          _OptionTile(
                            emoji: '✨',
                            title: 'Recording Quality',
                            subtitle: _settings.recordingQuality.toUpperCase(),
                            accentColor: const Color(0xFF4D96FF),
                            trailing: _KidsDropdown<String>(
                              value: _settings.recordingQuality,
                              accentColor: const Color(0xFF4D96FF),
                              items: const [
                                DropdownMenuItem(value: 'high',   child: Text('High')),
                                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                                DropdownMenuItem(value: 'low',    child: Text('Low')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                _save(_settings.copyWith(recordingQuality: v));
                              },
                            ),
                          ),
                          _Divider(),
                          _OptionTile(
                            emoji: '📊',
                            title: 'Max Level',
                            subtitle: '${_settings.maxLevel} levels',
                            accentColor: const Color(0xFF6BCB77),
                            trailing: _KidsDropdown<int>(
                              value: _settings.maxLevel,
                              accentColor: const Color(0xFF6BCB77),
                              items: const [
                                DropdownMenuItem(value: 10, child: Text('10')),
                                DropdownMenuItem(value: 20, child: Text('20')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                _save(_settings.copyWith(maxLevel: v));
                              },
                            ),
                          ),
                          _Divider(),
                          _OptionTile(
                            emoji: '⏱️',
                            title: 'Countdown',
                            subtitle: _settings.countdownSeconds == 0
                                ? 'Off'
                                : '${_settings.countdownSeconds} seconds',
                            accentColor: const Color(0xFFFF9F1C),
                            trailing: _KidsDropdown<int>(
                              value: _settings.countdownSeconds,
                              accentColor: const Color(0xFFFF9F1C),
                              items: const [
                                DropdownMenuItem(value: 0, child: Text('Off')),
                                DropdownMenuItem(value: 3, child: Text('3s')),
                                DropdownMenuItem(value: 5, child: Text('5s')),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                _save(_settings.copyWith(countdownSeconds: v));
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Data ──
                      _SectionLabel(emoji: '🗂️', label: 'Data'),
                      const SizedBox(height: 10),
                      _SettingCard(
                        children: [
                          _OptionTile(
                            emoji: '👤',
                            title: 'Go to Profile',
                            subtitle: 'Parent & child info',
                            accentColor: const Color(0xFF4D96FF),
                            trailing: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4D96FF).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 15, color: Color(0xFF4D96FF)),
                            ),
                            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                          ),
                          _Divider(),
                          _ResetTile(onReset: _resetConfirm),
                        ],
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

// ═══════════════════════════════════════════════════════════
//  Mic permission tile
// ═══════════════════════════════════════════════════════════

class _MicTile extends StatelessWidget {
  final bool granted;
  final VoidCallback onCheck;
  const _MicTile({required this.granted, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    final color = granted ? const Color(0xFF6BCB77) : const Color(0xFFFF6B6B);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(granted ? '🎤' : '🚫', style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Microphone',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D))),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      granted ? 'Granted' : 'Not Granted',
                      style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCheck,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text('Check',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Option tile
// ═══════════════════════════════════════════════════════════

class _OptionTile extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.trailing,
    this.onTap,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null ? (_) { setState(() => _pressed = false); widget.onTap!(); } : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _pressed ? widget.accentColor.withOpacity(0.06) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: widget.accentColor.withOpacity(0.13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D))),
                  const SizedBox(height: 2),
                  Text(widget.subtitle,
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Reset tile
// ═══════════════════════════════════════════════════════════

class _ResetTile extends StatelessWidget {
  final VoidCallback onReset;
  const _ResetTile({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Text('🗑️', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reset App Data',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D))),
                const SizedBox(height: 2),
                Text('Delete profile, recordings & settings',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFCC3333), blurRadius: 0, offset: Offset(0, 4)),
                ],
              ),
              child: const Text('Reset',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Kids Dropdown
// ═══════════════════════════════════════════════════════════

class _KidsDropdown<T> extends StatelessWidget {
  final T value;
  final Color accentColor;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _KidsDropdown({
    required this.value,
    required this.accentColor,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.30), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: accentColor, size: 20),
          style: TextStyle(color: accentColor, fontWeight: FontWeight.w800, fontSize: 13),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Setting Card wrapper
// ═══════════════════════════════════════════════════════════

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(height: 1.5, color: const Color(0xFFF0E8DF)),
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
        Text(label,
            style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w900,
              color: Color(0xFF3D3D3D), letterSpacing: -0.2,
            )),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(color: const Color(0xFFE8E0D5), borderRadius: BorderRadius.circular(2)),
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
            BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 8)),
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
            _NavItem(emoji: '⚙️', label: 'Options', onTap: () {}), // current screen
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
    final bool isCurrent = widget.label == 'Options';
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
            color: isCurrent
                ? Colors.white.withOpacity(0.16)
                : (_pressed ? Colors.white.withOpacity(0.10) : Colors.transparent),
            borderRadius: BorderRadius.circular(18),
            border: isCurrent
                ? Border.all(color: Colors.white.withOpacity(0.25), width: 1)
                : null,
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
                    color: isCurrent ? Colors.white : Colors.white.withOpacity(0.70),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Animal Painters
// ═══════════════════════════════════════════════════════════

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

    canvas.drawCircle(Offset(cx, cy), r, p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.35, cy - r * 0.10), width: r * 0.34, height: r * 0.28), white);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.35, cy - r * 0.10), width: r * 0.34, height: r * 0.28), white);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.35, cy - r * 0.10), width: r * 0.11, height: r * 0.24), black);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.35, cy - r * 0.10), width: r * 0.11, height: r * 0.24), black);
    canvas.drawCircle(Offset(cx - r * 0.28, cy - r * 0.16), r * 0.05, white);
    canvas.drawCircle(Offset(cx + r * 0.42, cy - r * 0.16), r * 0.05, white);

    final nose = Path()
      ..moveTo(cx, cy + r * 0.10)
      ..lineTo(cx - r * 0.11, cy + r * 0.22)
      ..lineTo(cx + r * 0.11, cy + r * 0.22)
      ..close();
    canvas.drawPath(nose, pink);

    final wPaint = Paint()
      ..color = white.color
      ..strokeWidth = size.width * 0.028
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final d in [-1.0, 1.0]) {
      canvas.drawLine(Offset(cx + d * r * 0.14, cy + r * 0.22), Offset(cx + d * r * 0.90, cy + r * 0.10), wPaint);
      canvas.drawLine(Offset(cx + d * r * 0.14, cy + r * 0.30), Offset(cx + d * r * 0.90, cy + r * 0.38), wPaint);
    }

    final smile = Path()
      ..moveTo(cx - r * 0.16, cy + r * 0.28)
      ..quadraticBezierTo(cx, cy + r * 0.46, cx + r * 0.16, cy + r * 0.28);
    canvas.drawPath(smile, Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.038
      ..strokeCap = StrokeCap.round);

    canvas.drawCircle(Offset(cx - r * 0.58, cy + r * 0.18), r * 0.16, Paint()..color = Colors.pink.withOpacity(0.35));
    canvas.drawCircle(Offset(cx + r * 0.58, cy + r * 0.18), r * 0.16, Paint()..color = Colors.pink.withOpacity(0.35));
  }

  @override
  bool shouldRepaint(covariant _CatPainter old) => old.color != color;
}

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

    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.55), width: r * 1.6, height: r * 1.2), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.28, cy + r * 0.72), width: r * 0.9, height: r * 0.55),
        Paint()..color = color.withOpacity(0.50));
    canvas.drawCircle(Offset(cx, cy - r * 0.08), r, p);
    final tuft = Path()
      ..moveTo(cx - r * 0.10, cy - r * 0.94)
      ..quadraticBezierTo(cx + r * 0.04, cy - r * 1.45, cx + r * 0.18, cy - r * 0.96)
      ..close();
    canvas.drawPath(tuft, p);
    final beak = Path()
      ..moveTo(cx + r * 0.80, cy - r * 0.06)
      ..lineTo(cx + r * 1.25, cy + r * 0.06)
      ..lineTo(cx + r * 0.80, cy + r * 0.20)
      ..close();
    canvas.drawPath(beak, orange);
    canvas.drawCircle(Offset(cx + r * 0.30, cy - r * 0.20), r * 0.16, white);
    canvas.drawCircle(Offset(cx + r * 0.32, cy - r * 0.18), r * 0.09, black);
    canvas.drawCircle(Offset(cx + r * 0.37, cy - r * 0.22), r * 0.04, white);
    canvas.drawCircle(Offset(cx + r * 0.52, cy + r * 0.10), r * 0.14,
        Paint()..color = Colors.pink.withOpacity(0.40));
  }

  @override
  bool shouldRepaint(covariant _DuckPainter old) => old.color != color;
}

// ─── Blob helper ─────────────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}