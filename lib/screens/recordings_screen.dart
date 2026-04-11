import 'dart:math';
import 'package:flutter/material.dart';

import '../models/parent_profile.dart';
import '../models/recording_item.dart';
import '../routes.dart';
import '../services/local_db.dart';

// ═══════════════════════════════════════════════════════════
//  RecordingsScreen — grouped by profile (reports view)
// ═══════════════════════════════════════════════════════════

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen>
    with TickerProviderStateMixin {
  List<ParentProfile> _profiles = [];
  Map<String, List<RecordingItem>> _recordingsByProfile = {};

  late final AnimationController _bgFloat1;
  late final AnimationController _bgFloat2;
  late final AnimationController _floatCtrl;

  List<AnimationController> _cardControllers = [];
  List<Animation<double>> _cardFades = [];
  List<Animation<Offset>> _cardSlides = [];

  static const _profileColors = [
    Color(0xFF4D96FF),
    Color(0xFF6BCB77),
    Color(0xFFFF9F1C),
    Color(0xFFB66DFF),
    Color(0xFFFF6B6B),
    Color(0xFF00C9B1),
  ];

  Color _colorFor(int i) => _profileColors[i % _profileColors.length];

  @override
  void initState() {
    super.initState();

    _bgFloat1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat(reverse: true);
    _bgFloat2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat(reverse: true);

    _refresh();
  }

  void _refresh() {
    final profiles = LocalDb.getProfiles();
    final allRecordings = LocalDb.getRecordings();

    final map = <String, List<RecordingItem>>{};
    for (final p in profiles) {
      map[p.id] = allRecordings.where((r) => r.profileId == p.id).toList();
    }

    setState(() {
      _profiles = profiles;
      _recordingsByProfile = map;
    });

    _disposeCardAnimations();
    _initCardAnimations(profiles.length);
  }

  void _initCardAnimations(int count) {
    _cardControllers = List.generate(
      count,
      (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 500)),
    );
    _cardFades = _cardControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _cardSlides = _cardControllers
        .map((c) => Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)))
        .toList();
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 80 + i * 100), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  void _disposeCardAnimations() {
    for (final c in _cardControllers) c.dispose();
    _cardControllers = [];
    _cardFades = [];
    _cardSlides = [];
  }

  @override
  void dispose() {
    _bgFloat1.dispose();
    _bgFloat2.dispose();
    _floatCtrl.dispose();
    _disposeCardAnimations();
    super.dispose();
  }

  int get _totalRecordings => _recordingsByProfile.values.fold(0, (s, l) => s + l.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E8),
      body: Stack(
        children: [
          // Blobs
          Positioned(top: -70, left: -50, child: _Blob(color: const Color(0xFFD6FFE4), size: 240)),
          Positioned(top: 80, right: -60, child: _Blob(color: const Color(0xFFD6ECFF), size: 200)),
          Positioned(bottom: 130, left: -50, child: _Blob(color: const Color(0xFFFFDFDF), size: 210)),
          Positioned(bottom: -50, right: 0, child: _Blob(color: const Color(0xFFFFF0C8), size: 180)),

          // Floating bg animals
          AnimatedBuilder(
            animation: _bgFloat1,
            builder: (_, __) => Positioned(
              top: 95 + sin(_bgFloat1.value * pi) * 10,
              right: -22,
              child: Opacity(
                opacity: 0.11,
                child: Transform.rotate(
                  angle: 0.18,
                  child: CustomPaint(size: const Size(100, 100), painter: const _DuckPainter(color: Color(0xFF6BCB77))),
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
                opacity: 0.10,
                child: Transform.rotate(
                  angle: -0.15,
                  child: CustomPaint(size: const Size(90, 90), painter: const _BearPainter(color: Color(0xFF4D96FF))),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Tap a patient to view their recordings 🎵',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildBody()),
                const SizedBox(height: 12),
                _BottomBar(screenContext: context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF3D3D3D)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(children: [
                    TextSpan(text: 'Patient ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF3D3D3D))),
                    TextSpan(text: 'Reports', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF9C8AE6))),
                  ]),
                ),
                Text(
                  '${_profiles.length} patient${_profiles.length == 1 ? '' : 's'} · $_totalRecordings recording${_totalRecordings == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_profiles.isEmpty) {
      return _EmptyState(floatCtrl: _floatCtrl);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: _profiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final profile = _profiles[i];
        final recs = _recordingsByProfile[profile.id] ?? [];
        final color = _colorFor(i);

        Widget card = _ProfileReportCard(
          profile: profile,
          recordings: recs,
          accentColor: color,
          index: i,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileRecordingsScreen(
                profile: profile,
                accentColor: color,
              ),
            ),
          ).then((_) => _refresh()),
        );

        if (i < _cardFades.length) {
          card = FadeTransition(
            opacity: _cardFades[i],
            child: SlideTransition(position: _cardSlides[i], child: card),
          );
        }

        return card;
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Profile Report Card
// ═══════════════════════════════════════════════════════════

class _ProfileReportCard extends StatefulWidget {
  final ParentProfile profile;
  final List<RecordingItem> recordings;
  final Color accentColor;
  final int index;
  final VoidCallback onTap;

  const _ProfileReportCard({
    required this.profile,
    required this.recordings,
    required this.accentColor,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ProfileReportCard> createState() => _ProfileReportCardState();
}

class _ProfileReportCardState extends State<_ProfileReportCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final recs = widget.recordings;
    final count = recs.length;
    final peakLevel = recs.isEmpty ? 0 : recs.map((r) => r.level).reduce(max);
    final lastDate = recs.isEmpty ? null : recs.first.createdAt;
    final name = widget.profile.childName.trim().isEmpty ? 'Patient ${widget.index + 1}' : widget.profile.childName;
    final parentName = widget.profile.parentName.trim().isEmpty ? '' : widget.profile.parentName;
    final color = widget.accentColor;
    final shadowColor = HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness - 0.18).clamp(0.0, 1.0)).toColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 5)),
              BoxShadow(color: shadowColor.withOpacity(0.35), blurRadius: 0, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              // ── Top colored band ──
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Row(
                  children: [
                    // Avatar circle
                    Container(
                      width: 58, height: 58,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.14),
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withOpacity(0.35), width: 2.5),
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D))),
                          if (parentName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text('👨‍👩‍👧 $parentName', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _StatChip(label: '$count recording${count == 1 ? '' : 's'}', emoji: '🎙️', color: color),
                              const SizedBox(width: 8),
                              _StatChip(label: 'Peak $peakLevel', emoji: '⭐', color: const Color(0xFFFF9F1C)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow + last date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: shadowColor, blurRadius: 0, offset: const Offset(0, 3))],
                          ),
                          child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                        ),
                        if (lastDate != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _formatShortDate(lastDate),
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Progress bar (fill = % of max recordings across profiles) ──
              if (count > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: _MiniProgressBar(color: color, value: count, label: '$count sessions'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatShortDate(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  const _StatChip({required this.label, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _MiniProgressBar extends StatelessWidget {
  final Color color;
  final int value;
  final String label;
  const _MiniProgressBar({required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    // simple visual bar — fills based on value (capped at 20 for display)
    final fraction = (value / 20).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(height: 6, color: color.withOpacity(0.12)),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                widthFactor: fraction,
                child: Container(height: 6, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ProfileRecordingsScreen — all recordings for one profile
// ═══════════════════════════════════════════════════════════

class ProfileRecordingsScreen extends StatefulWidget {
  final ParentProfile profile;
  final Color accentColor;

  const ProfileRecordingsScreen({
    super.key,
    required this.profile,
    required this.accentColor,
  });

  @override
  State<ProfileRecordingsScreen> createState() => _ProfileRecordingsScreenState();
}

class _ProfileRecordingsScreenState extends State<ProfileRecordingsScreen>
    with TickerProviderStateMixin {
  List<RecordingItem> _items = [];

  late final AnimationController _floatCtrl;
  late final AnimationController _pulseCtrl;

  List<AnimationController> _cardControllers = [];
  List<Animation<double>> _cardFades = [];
  List<Animation<Offset>> _cardSlides = [];

  static const _cardColors = [
    Color(0xFF4D96FF), Color(0xFF6BCB77), Color(0xFFFF9F1C),
    Color(0xFFB66DFF), Color(0xFFFF6B6B), Color(0xFF00C9B1),
  ];

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat(reverse: true);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _refresh();
  }

  void _refresh() {
    final items = LocalDb.getRecordings(profileId: widget.profile.id);
    setState(() => _items = items);
    _disposeCardAnimations();
    _initCardAnimations(items.length);
  }

  void _initCardAnimations(int count) {
    _cardControllers = List.generate(
      count,
      (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 480)),
    );
    _cardFades = _cardControllers.map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut)).toList();
    _cardSlides = _cardControllers.map((c) =>
      Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero)
          .animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack))).toList();
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 60 + i * 80), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  void _disposeCardAnimations() {
    for (final c in _cardControllers) c.dispose();
    _cardControllers = []; _cardFades = []; _cardSlides = [];
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _disposeCardAnimations();
    super.dispose();
  }

  Future<void> _confirmDelete(RecordingItem r) async {
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
              const Text('🗑️', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 10),
              const Text('Delete Recording?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF3D3D3D)), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text('This recording will be permanently deleted.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(height: 46, decoration: BoxDecoration(color: const Color(0xFFE8E0D5), borderRadius: BorderRadius.circular(14)),
                    child: const Center(child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF3D3D3D))))),
                )),
                const SizedBox(width: 12),
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.pop(context, true),
                  child: Container(height: 46,
                    decoration: BoxDecoration(color: const Color(0xFFFF6B6B), borderRadius: BorderRadius.circular(14),
                      boxShadow: const [BoxShadow(color: Color(0xFFCC3333), blurRadius: 0, offset: Offset(0, 4))]),
                    child: const Center(child: Text('Delete', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)))),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
    if (confirm == true) {
      await LocalDb.deleteRecording(r.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.childName.trim().isEmpty ? 'Patient' : widget.profile.childName;
    final color = widget.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E8),
      body: Stack(
        children: [
          Positioned(top: -70, left: -50, child: _Blob(color: const Color(0xFFD6FFE4), size: 220)),
          Positioned(top: 80, right: -60, child: _Blob(color: const Color(0xFFD6ECFF), size: 190)),
          Positioned(bottom: -50, right: 0, child: _Blob(color: const Color(0xFFFFF0C8), size: 170)),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF3D3D3D)),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Avatar
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.14),
                          shape: BoxShape.circle,
                          border: Border.all(color: color.withOpacity(0.40), width: 2),
                        ),
                        child: Center(
                          child: Text(name[0].toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D))),
                            Text('${_items.length} recording${_items.length == 1 ? '' : 's'}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // List
                Expanded(
                  child: _items.isEmpty
                      ? _ProfileEmptyState(name: name, color: color, floatCtrl: _floatCtrl)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final r = _items[i];
                            final cardColor = _cardColors[i % _cardColors.length];

                            Widget card = _RecordingCard(
                              item: r,
                              index: i,
                              accentColor: cardColor,
                              pulseCtrl: _pulseCtrl,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.recordingDetails,
                                arguments: r.toJson(),
                              ).then((_) => _refresh()),
                              onDelete: () => _confirmDelete(r),
                            );

                            if (i < _cardFades.length) {
                              card = FadeTransition(
                                opacity: _cardFades[i],
                                child: SlideTransition(position: _cardSlides[i], child: card),
                              );
                            }
                            return card;
                          },
                        ),
                ),

                const SizedBox(height: 12),
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
//  Recording Card (inside a profile)
// ═══════════════════════════════════════════════════════════

class _RecordingCard extends StatefulWidget {
  final RecordingItem item;
  final int index;
  final Color accentColor;
  final AnimationController pulseCtrl;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecordingCard({
    required this.item,
    required this.index,
    required this.accentColor,
    required this.pulseCtrl,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_RecordingCard> createState() => _RecordingCardState();
}

class _RecordingCardState extends State<_RecordingCard> {
  bool _pressed = false;

  static const _modeNames = {'1': 'Classic', '2': 'Rounded', '3': 'Thick Meter', '4': 'Playful'};
  static const _modeEmojis = {'1': '⚡', '2': '✨', '3': '💪', '4': '🎉'};

  @override
  Widget build(BuildContext context) {
    final r = widget.item;
    final color = widget.accentColor;
    final modeName = _modeNames[r.modeId] ?? 'Mode ${r.modeId}';
    final modeEmoji = _modeEmojis[r.modeId] ?? '🎙️';
    final shadowColor = HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness - 0.18).clamp(0.0, 1.0)).toColor();

    final date = _formatDate(r.createdAt);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4)),
              BoxShadow(color: shadowColor.withOpacity(0.30), blurRadius: 0, offset: const Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: shadowColor, blurRadius: 0, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: Text('${widget.index + 1}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: color.withOpacity(0.13), borderRadius: BorderRadius.circular(8)),
                            child: Text('$modeEmoji $modeName',
                              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
                          ),
                          const SizedBox(width: 6),
                          Text('⭐ ${r.level}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF3D3D3D))),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),

                // Play hint + delete
                Column(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.play_arrow_rounded, color: color, size: 20),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(color: const Color(0xFFFF6B6B).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: const Center(child: Text('🗑️', style: TextStyle(fontSize: 15))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final mm = d.minute.toString().padLeft(2, '0');
    return '${months[d.month-1]} ${d.day}, ${d.year} · $h:$mm $ampm';
  }
}

// ═══════════════════════════════════════════════════════════
//  Empty States
// ═══════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final AnimationController floatCtrl;
  const _EmptyState({required this.floatCtrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: floatCtrl,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, sin(floatCtrl.value * pi) * 8),
              child: child,
            ),
            child: CustomPaint(size: const Size(110, 110), painter: const _DuckPainter(color: Color(0xFF6BCB77))),
          ),
          const SizedBox(height: 20),
          const Text('No patients yet!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF3D3D3D))),
          const SizedBox(height: 6),
          Text('Add a patient profile first 👨‍👩‍👧', style: TextStyle(fontSize: 13.5, color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF9C8AE6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Color(0xFF6D5CC7), blurRadius: 0, offset: Offset(0, 5))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('👤', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Add Patient', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEmptyState extends StatelessWidget {
  final String name;
  final Color color;
  final AnimationController floatCtrl;
  const _ProfileEmptyState({required this.name, required this.color, required this.floatCtrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: floatCtrl,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, sin(floatCtrl.value * pi) * 8),
              child: child,
            ),
            child: CustomPaint(size: const Size(100, 100), painter: _DuckPainter(color: color)),
          ),
          const SizedBox(height: 20),
          Text('No recordings for $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF3D3D3D))),
          const SizedBox(height: 6),
          Text('Start a session to see results here 🎙️', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.modeSelect),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: color.withOpacity(0.55), blurRadius: 0, offset: const Offset(0, 5))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🎙️', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Start Recording', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Bottom Bar
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(emoji: '🏠', label: 'Home', onTap: () => Navigator.pushNamedAndRemoveUntil(screenContext, AppRoutes.home, (r) => false)),
            _NavItem(emoji: '🎙️', label: 'Start', onTap: () => Navigator.pushNamed(screenContext, AppRoutes.modeSelect)),
            _NavItem(emoji: '⚙️', label: 'Options', onTap: () => Navigator.pushNamed(screenContext, AppRoutes.settings)),
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
            color: _pressed ? Colors.white.withOpacity(0.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 3),
              Text(widget.label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.80))),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Painters & Helpers
// ═══════════════════════════════════════════════════════════

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

class _DuckPainter extends CustomPainter {
  final Color color;
  const _DuckPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final orange = Paint()..color = const Color(0xFFFF8C00);
    final black = Paint()..color = const Color(0xFF1A1A1A);
    final white = Paint()..color = Colors.white.withOpacity(0.92);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.30;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.55), width: r * 1.6, height: r * 1.2), p);
    canvas.drawCircle(Offset(cx, cy - r * 0.08), r, p);
    final beak = Path()
      ..moveTo(cx + r * 0.80, cy - r * 0.06)
      ..lineTo(cx + r * 1.25, cy + r * 0.06)
      ..lineTo(cx + r * 0.80, cy + r * 0.20)
      ..close();
    canvas.drawPath(beak, orange);
    canvas.drawCircle(Offset(cx + r * 0.30, cy - r * 0.20), r * 0.16, white);
    canvas.drawCircle(Offset(cx + r * 0.32, cy - r * 0.18), r * 0.09, black);
  }

  @override
  bool shouldRepaint(covariant _DuckPainter old) => old.color != color;
}

class _BearPainter extends CustomPainter {
  final Color color;
  const _BearPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.34;
    canvas.drawCircle(Offset(cx - r * 0.68, cy - r * 0.74), r * 0.36, p);
    canvas.drawCircle(Offset(cx + r * 0.68, cy - r * 0.74), r * 0.36, p);
    canvas.drawCircle(Offset(cx, cy), r, p);
  }

  @override
  bool shouldRepaint(covariant _BearPainter old) => old.color != color;
}