import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/recording_item.dart';
import '../routes.dart';
import '../services/local_db.dart';
import '../services/share_service.dart';

// ═══════════════════════════════════════════════════════════
//  RecordingsScreen — Kids Playful UI
// ═══════════════════════════════════════════════════════════

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();

  List<RecordingItem> items = [];
  String? _currentlyPlayingId;
  PlayerState _playerState = PlayerState.stopped;

  late final AnimationController _floatCtrl;
  late final AnimationController _bgFloat1;
  late final AnimationController _bgFloat2;
  late final AnimationController _pulseCtrl;

  // Card entrance animations
  List<AnimationController> _cardControllers = [];
  List<Animation<double>> _cardFades = [];
  List<Animation<Offset>> _cardSlides = [];

  // Accent colors cycling per card
  final List<Color> _cardColors = const [
    Color(0xFF4D96FF),
    Color(0xFF6BCB77),
    Color(0xFFFF9F1C),
    Color(0xFFB66DFF),
    Color(0xFFFF6B6B),
  ];

  @override
  void initState() {
    super.initState();
    _refresh();

    _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _playerState = s);
    });
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _currentlyPlayingId = null;
        _playerState = PlayerState.stopped;
      });
    });

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _bgFloat1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _bgFloat2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _initCardAnimations();
  }

  void _initCardAnimations() {
    final count = items.isEmpty ? 0 : items.length;
    _cardControllers = List.generate(
      count,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 480),
      ),
    );
    _cardFades = _cardControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _cardSlides = _cardControllers
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.20),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutBack)),
        )
        .toList();
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 + i * 90), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  void _disposeCardAnimations() {
    for (final c in _cardControllers) {
      c.dispose();
    }
    _cardControllers = [];
    _cardFades = [];
    _cardSlides = [];
  }

  @override
  void dispose() {
    _player.dispose();
    _floatCtrl.dispose();
    _bgFloat1.dispose();
    _bgFloat2.dispose();
    _pulseCtrl.dispose();
    _disposeCardAnimations();
    super.dispose();
  }

  void _refresh() {
    final next = LocalDb.getRecordings();

    setState(() {
      items = next;
    });

    _disposeCardAnimations();
    _initCardAnimations();
  }

  bool _isItemPlaying(String id) =>
      _currentlyPlayingId == id && _playerState == PlayerState.playing;

  bool _isItemPaused(String id) =>
      _currentlyPlayingId == id && _playerState == PlayerState.paused;

  Future<void> _playOrPause(RecordingItem r) async {
    final f = File(r.filePath);
    if (!f.existsSync()) {
      _showSnack('File missing ❌', const Color(0xFFFF6B6B));
      return;
    }
    if (_isItemPlaying(r.id)) {
      await _player.pause();
      return;
    }
    if (_isItemPaused(r.id)) {
      await _player.resume();
      return;
    }
    await _player.stop();
    setState(() => _currentlyPlayingId = r.id);
    await _player.play(DeviceFileSource(r.filePath));
  }

  Future<void> _stop() async {
    await _player.stop();
    if (!mounted) return;
    setState(() {
      _currentlyPlayingId = null;
      _playerState = PlayerState.stopped;
    });
  }

  Future<void> _delete(RecordingItem r) async {
    if (_currentlyPlayingId == r.id) await _stop();
    try {
      final f = File(r.filePath);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
    await LocalDb.deleteRecording(r.id);
    _refresh();
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
              const Text(
                'Delete Recording?',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D3D3D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'This recording will be permanently deleted.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E0D5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
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
                        height: 46,
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
                        child: const Center(
                          child: Text(
                            'Delete',
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
    if (confirm == true) await _delete(r);
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _cardColor(int index) => _cardColors[index % _cardColors.length];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final heroTag = (args is Map && args['heroTag'] != null)
        ? args['heroTag'].toString()
        : 'hero_recordings';

    final isAnythingPlaying =
        _currentlyPlayingId != null && _playerState == PlayerState.playing;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E8),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Blobs ──
          Positioned(
            top: -70,
            left: -50,
            child: _Blob(color: const Color(0xFFD6FFE4), size: 240),
          ),
          Positioned(
            top: 80,
            right: -60,
            child: _Blob(color: const Color(0xFFD6ECFF), size: 200),
          ),
          Positioned(
            bottom: 130,
            left: -50,
            child: _Blob(color: const Color(0xFFFFDFDF), size: 210),
          ),
          Positioned(
            bottom: -50,
            right: 0,
            child: _Blob(color: const Color(0xFFFFF0C8), size: 180),
          ),

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
                  child: CustomPaint(
                    size: const Size(100, 100),
                    painter: const _DuckPainter(color: Color(0xFF6BCB77)),
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
                  angle: -0.15,
                  child: CustomPaint(
                    size: const Size(90, 90),
                    painter: const _BearPainter(color: Color(0xFF4D96FF)),
                  ),
                ),
              ),
            ),
          ),

          // ── Main Content ──
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      // Back
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

                      // Floating duck mascot
                      // AnimatedBuilder(
                      //   animation: _floatCtrl,
                      //   builder: (_, child) => Transform.translate(
                      //     offset: Offset(0, sin(_floatCtrl.value * pi) * 5),
                      //     child: child,
                      //   ),
                      //   child: Hero(
                      //     tag: heroTag,
                      //     child: CustomPaint(
                      //       size: const Size(46, 46),
                      //       painter: const _DuckPainter(
                      //         color: Color(0xFF6BCB77),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'My ',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF3D3D3D),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Recordings',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF9C8AE6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${items.length} recording${items.length == 1 ? '' : 's'} saved',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stop button (only when playing)
                      if (isAnythingPlaying)
                        GestureDetector(
                          onTap: _stop,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.stop_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Stop',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Listen and share your recordings 🎵',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Now playing banner
                if (_currentlyPlayingId != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _NowPlayingBanner(
                      isPlaying: _playerState == PlayerState.playing,
                      pulseCtrl: _pulseCtrl,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // List
                Expanded(
                  child: items.isEmpty
                      ? _EmptyState(floatCtrl: _floatCtrl)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final r = items[i];
                            final color = _cardColor(i);
                            final isPlaying = _isItemPlaying(r.id);
                            final isPaused = _isItemPaused(r.id);

                            Widget card = _RecordingCard(
                              item: r,
                              index: i,
                              accentColor: color,
                              isPlaying: isPlaying,
                              isPaused: isPaused,
                              pulseCtrl: _pulseCtrl,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.recordingDetails,
                                arguments: r.toJson(),
                              ).then((_) => _refresh()),
                              onPlayPause: () => _playOrPause(r),
                              onShare: () =>
                                  ShareService.shareAudioFile(r.filePath),
                              onDelete: () => _confirmDelete(r),
                            );

                            if (i < _cardFades.length) {
                              card = FadeTransition(
                                opacity: _cardFades[i],
                                child: SlideTransition(
                                  position: _cardSlides[i],
                                  child: card,
                                ),
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
//  Recording Card
// ═══════════════════════════════════════════════════════════

class _RecordingCard extends StatefulWidget {
  final RecordingItem item;
  final int index;
  final Color accentColor;
  final bool isPlaying;
  final bool isPaused;
  final AnimationController pulseCtrl;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _RecordingCard({
    required this.item,
    required this.index,
    required this.accentColor,
    required this.isPlaying,
    required this.isPaused,
    required this.pulseCtrl,
    required this.onTap,
    required this.onPlayPause,
    required this.onShare,
    required this.onDelete,
  });

  @override
  State<_RecordingCard> createState() => _RecordingCardState();
}

class _RecordingCardState extends State<_RecordingCard>
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
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'MMM d, yyyy • h:mm a',
    ).format(widget.item.createdAt);
    final isActive = widget.isPlaying || widget.isPaused;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: isActive
                ? Border.all(color: widget.accentColor, width: 2.5)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? widget.accentColor.withOpacity(0.30)
                    : Colors.black.withOpacity(0.07),
                blurRadius: isActive ? 18 : 12,
                offset: const Offset(0, 5),
              ),
              if (isActive)
                BoxShadow(
                  color: widget.accentColor,
                  blurRadius: 0,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // ── Left: animated icon ──
                GestureDetector(
                  onTap: widget.onPlayPause,
                  child: AnimatedBuilder(
                    animation: widget.pulseCtrl,
                    builder: (_, child) {
                      final scale = isActive
                          ? 1.0 + widget.pulseCtrl.value * 0.08
                          : 1.0;
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: widget.accentColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: widget.accentColor,
                            blurRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isPlaying
                            ? Icons.pause_rounded
                            : widget.isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // ── Middle: info ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Mode ${widget.item.modeId}',
                              style: TextStyle(
                                color: widget.accentColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '⭐ Level ${widget.item.level}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3D3D3D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.isPlaying)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _WaveformIndicator(
                            color: widget.accentColor,
                            pulseCtrl: widget.pulseCtrl,
                          ),
                        ),
                      if (widget.isPaused)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '⏸ Paused',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: widget.accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Right: action buttons ──
                Column(
                  children: [
                    _IconBtn(
                      emoji: '📤',
                      onTap: widget.onShare,
                      color: const Color(0xFF4D96FF),
                    ),
                    const SizedBox(height: 6),
                    _IconBtn(
                      emoji: '🗑️',
                      onTap: widget.onDelete,
                      color: const Color(0xFFFF6B6B),
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
}

// ═══════════════════════════════════════════════════════════
//  Waveform indicator (animated bars)
// ═══════════════════════════════════════════════════════════

class _WaveformIndicator extends StatelessWidget {
  final Color color;
  final AnimationController pulseCtrl;

  const _WaveformIndicator({required this.color, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(5, (i) {
            final phase = (pulseCtrl.value + i * 0.2) % 1.0;
            final height = 4.0 + sin(phase * pi) * 8.0;
            return Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Container(
                width: 3,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Now Playing Banner
// ═══════════════════════════════════════════════════════════

class _NowPlayingBanner extends StatelessWidget {
  final bool isPlaying;
  final AnimationController pulseCtrl;

  const _NowPlayingBanner({required this.isPlaying, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6BCB77),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF3A9947),
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0xFF3A9947),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, __) {
              final scale = isPlaying ? 1.0 + pulseCtrl.value * 0.15 : 1.0;
              return Transform.scale(
                scale: scale,
                child: const Text('🎵', style: TextStyle(fontSize: 20)),
              );
            },
          ),
          const SizedBox(width: 10),
          Text(
            isPlaying ? 'Now playing...' : 'Paused',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          _WaveformIndicator(color: Colors.white, pulseCtrl: pulseCtrl),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Empty State
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
            child: CustomPaint(
              size: const Size(110, 110),
              painter: const _DuckPainter(color: Color(0xFF6BCB77)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No recordings yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3D3D3D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap Start to record something fun 🎙️',
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.modeSelect),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF6BCB77),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF3A9947),
                    blurRadius: 0,
                    offset: Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Color(0xFF3A9947),
                    blurRadius: 14,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🎙️', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Start Recording',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
//  Small icon button
// ═══════════════════════════════════════════════════════════

class _IconBtn extends StatefulWidget {
  final String emoji;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(widget.emoji, style: const TextStyle(fontSize: 16)),
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
            _NavItem(
              emoji: '🏠',
              label: 'Home',
              isCurrent: false,
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                screenContext,
                AppRoutes.home,
                (r) => false,
              ),
            ),
            _NavItem(
              emoji: '🎙️',
              label: 'Start',
              isCurrent: false,
              onTap: () =>
                  Navigator.pushNamed(screenContext, AppRoutes.modeSelect),
            ),
            _NavItem(
              emoji: '⚙️',
              label: 'Options',
              isCurrent: false,
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
  final bool isCurrent;
  final VoidCallback onTap;
  const _NavItem({
    required this.emoji,
    required this.label,
    required this.isCurrent,
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
            color: widget.isCurrent
                ? Colors.white.withOpacity(0.16)
                : (_pressed
                      ? Colors.white.withOpacity(0.10)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(18),
            border: widget.isCurrent
                ? Border.all(color: Colors.white.withOpacity(0.25))
                : null,
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
                  color: widget.isCurrent
                      ? Colors.white
                      : Colors.white.withOpacity(0.70),
                ),
              ),
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

class _DuckPainter extends CustomPainter {
  final Color color;
  const _DuckPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final white = Paint()..color = Colors.white.withOpacity(0.92);
    final black = Paint()..color = const Color(0xFF1A1A1A);
    final orange = Paint()..color = const Color(0xFFFF8C00);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.30;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.55),
        width: r * 1.6,
        height: r * 1.2,
      ),
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + r * 0.28, cy + r * 0.72),
        width: r * 0.9,
        height: r * 0.55,
      ),
      Paint()..color = color.withOpacity(0.50),
    );
    canvas.drawCircle(Offset(cx, cy - r * 0.08), r, p);
    final tuft = Path()
      ..moveTo(cx - r * 0.10, cy - r * 0.94)
      ..quadraticBezierTo(
        cx + r * 0.04,
        cy - r * 1.45,
        cx + r * 0.18,
        cy - r * 0.96,
      )
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
    canvas.drawCircle(
      Offset(cx + r * 0.52, cy + r * 0.10),
      r * 0.14,
      Paint()..color = Colors.pink.withOpacity(0.40),
    );
  }

  @override
  bool shouldRepaint(covariant _DuckPainter old) => old.color != color;
}

class _BearPainter extends CustomPainter {
  final Color color;
  const _BearPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final dark = Paint()..color = color.withOpacity(0.55);
    final white = Paint()..color = Colors.white.withOpacity(0.92);
    final black = Paint()..color = const Color(0xFF1A1A1A);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.34;

    canvas.drawCircle(Offset(cx - r * 0.68, cy - r * 0.74), r * 0.36, p);
    canvas.drawCircle(Offset(cx + r * 0.68, cy - r * 0.74), r * 0.36, p);
    canvas.drawCircle(Offset(cx - r * 0.68, cy - r * 0.74), r * 0.20, dark);
    canvas.drawCircle(Offset(cx + r * 0.68, cy - r * 0.74), r * 0.20, dark);
    canvas.drawCircle(Offset(cx, cy), r, p);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.34),
        width: r * 0.96,
        height: r * 0.60,
      ),
      dark,
    );
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
    canvas.drawPath(
      smile,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.040
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(cx - r * 0.58, cy + r * 0.16),
      r * 0.16,
      Paint()..color = Colors.pink.withOpacity(0.38),
    );
    canvas.drawCircle(
      Offset(cx + r * 0.58, cy + r * 0.16),
      r * 0.16,
      Paint()..color = Colors.pink.withOpacity(0.38),
    );
  }

  @override
  bool shouldRepaint(covariant _BearPainter old) => old.color != color;
}

// ─── Blob ─────────────────────────────────────────────────
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
