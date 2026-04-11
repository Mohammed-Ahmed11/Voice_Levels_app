import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/recording_item.dart';
import '../services/share_service.dart';

class RecordingDetailsScreen extends StatefulWidget {
  const RecordingDetailsScreen({super.key});

  @override
  State<RecordingDetailsScreen> createState() => _RecordingDetailsScreenState();
}

class _RecordingDetailsScreenState extends State<RecordingDetailsScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _state = PlayerState.stopped;
  RecordingItem? _item;

  bool get _isPlaying => _state == PlayerState.playing;
  bool get _isPaused => _state == PlayerState.paused;

  late final AnimationController _floatCtrl;
  late final AnimationController _bgFloat1;
  late final AnimationController _bgFloat2;
  late final AnimationController _pulseCtrl;
  late final AnimationController _discCtrl;

  static const Color _accent = Color(0xFF6BCB77);

  @override
  void initState() {
    super.initState();

    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _state = s);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _position = Duration.zero);
    });

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat(reverse: true);
    _bgFloat1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400))..repeat(reverse: true);
    _bgFloat2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat(reverse: true);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _discCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    _item = args is Map ? RecordingItem.fromJson(Map<String, dynamic>.from(args)) : null;
  }

  @override
  void dispose() {
    _player.dispose();
    _floatCtrl.dispose();
    _bgFloat1.dispose();
    _bgFloat2.dispose();
    _pulseCtrl.dispose();
    _discCtrl.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    final item = _item;
    if (item == null) return;
    final f = File(item.filePath);
    if (!f.existsSync()) {
      _showSnack('File missing ❌', const Color(0xFFFF6B6B));
      return;
    }
    await _player.play(DeviceFileSource(item.filePath), position: _position);
  }

  Future<void> _pause() async => _player.pause();

  Future<void> _stop() async {
    await _player.stop();
    if (!mounted) return;
    setState(() => _position = Duration.zero);
  }

  Future<void> _seekTo(double seconds) async => _player.seek(Duration(seconds: seconds.toInt()));

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    if (item == null) {
      return const Scaffold(backgroundColor: Color(0xFFFFF4E8), body: Center(child: Text('No data')));
    }

    final maxSec = _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0;
    final posSec = _position.inSeconds.clamp(0, _duration.inSeconds).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () { _stop(); Navigator.pop(context); },
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
                  const SizedBox(width: 12),
                  const Text('Recording Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF3D3D3D))),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  Center(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_discCtrl, _pulseCtrl]),
                      builder: (_, __) {
                        final angle = _isPlaying ? _discCtrl.value * 2 * pi : 0.0;
                        final glowOpacity = _isPlaying ? 0.3 + _pulseCtrl.value * 0.2 : 0.10;

                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: _accent.withOpacity(glowOpacity), blurRadius: 40, spreadRadius: 8),
                            ],
                          ),
                          child: Transform.rotate(
                            angle: angle,
                            child: CustomPaint(
                              size: const Size(180, 180),
                              painter: _VinylPainter(color: _accent),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 18, offset: const Offset(0, 6))],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(_position), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: _accent)),
                            if (_isPlaying)
                              AnimatedBuilder(
                                animation: _pulseCtrl,
                                builder: (_, __) => Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(6, (i) {
                                    // ✅ FIX: clamp height (no negative)
                                    final raw = 4.0 + sin((_pulseCtrl.value + i * 0.18) * pi) * 10;
                                    final h = raw.clamp(2.0, 16.0);
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 3),
                                      child: Container(
                                        width: 3.5,
                                        height: h,
                                        decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(2)),
                                      ),
                                    );
                                  }),
                                ),
                              )
                            else
                              Text('🎵', style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
                            Text(_fmt(_duration), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.grey.shade400)),
                          ],
                        ),

                        const SizedBox(height: 14),

                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: _accent,
                            inactiveTrackColor: _accent.withOpacity(0.18),
                            thumbColor: _accent,
                            overlayColor: _accent.withOpacity(0.20),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                            trackHeight: 6,
                          ),
                          child: Slider(
                            value: posSec,
                            min: 0,
                            max: maxSec,
                            onChanged: _seekTo,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CtrlBtn(emoji: '⏹️', label: 'Stop', color: const Color(0xFFFF6B6B), onTap: _stop, size: 52),
                            const SizedBox(width: 20),
                            _CtrlBtn(
                              emoji: _isPlaying ? '⏸️' : '▶️',
                              label: _isPlaying ? 'Pause' : _isPaused ? 'Resume' : 'Play',
                              color: _accent,
                              onTap: _isPlaying ? _pause : _play,
                              size: 72,
                              isMain: true,
                            ),
                            const SizedBox(width: 20),
                            _CtrlBtn(
                              emoji: '⏪',
                              label: '-5s',
                              color: const Color(0xFFB66DFF),
                              onTap: () => _seekTo((posSec - 5).clamp(0, maxSec)),
                              size: 52,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _ActionBtn(
                          emoji: '📤',
                          label: 'Share',
                          color: const Color(0xFF4D96FF),
                          onTap: () => ShareService.shareAudioFile(item.filePath),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionBtn(
                          emoji: '🔍',
                          label: 'Check File',
                          color: const Color(0xFFFF9F1C),
                          onTap: () {
                            final exists = File(item.filePath).existsSync();
                            _showSnack(exists ? 'File exists ✅' : 'File missing ❌', exists ? _accent : const Color(0xFFFF6B6B));
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VinylPainter extends CustomPainter {
  final Color color;
  const _VinylPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFF2D2D2D));

    for (int i = 1; i <= 7; i++) {
      canvas.drawCircle(
        Offset(cx, cy),
        r * (0.90 - i * 0.07),
        Paint()
          ..color = const Color(0xFF3A3A3A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    canvas.drawCircle(Offset(cx, cy), r * 0.36, Paint()..color = color);
    canvas.drawCircle(Offset(cx, cy), r * 0.28, Paint()..color = color.withOpacity(0.65));
    canvas.drawCircle(Offset(cx, cy), r * 0.07, Paint()..color = const Color(0xFF1A1A1A));
  }

  @override
  bool shouldRepaint(covariant _VinylPainter old) => old.color != color;
}

class _CtrlBtn extends StatefulWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double size;
  final bool isMain;

  const _CtrlBtn({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
    required this.size,
    this.isMain = false,
  });

  @override
  State<_CtrlBtn> createState() => _CtrlBtnState();
}

class _CtrlBtnState extends State<_CtrlBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: widget.color, blurRadius: 0, offset: Offset(0, widget.isMain ? 6 : 4)),
                  BoxShadow(color: widget.color.withOpacity(0.28), blurRadius: 16, offset: Offset(0, widget.isMain ? 10 : 6)),
                ],
              ),
              child: Center(child: Text(widget.emoji, style: TextStyle(fontSize: widget.isMain ? 28 : 20))),
            ),
            const SizedBox(height: 6),
            Text(widget.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.emoji, required this.label, required this.color, required this.onTap});

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: widget.color, blurRadius: 0, offset: const Offset(0, 5)),
              BoxShadow(color: widget.color.withOpacity(0.28), blurRadius: 16, offset: const Offset(0, 10)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}