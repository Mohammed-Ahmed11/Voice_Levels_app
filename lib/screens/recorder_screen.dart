import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../models/recording_item.dart';
import '../models/app_settings.dart';
import '../services/local_db.dart';
import '../services/settings_service.dart';
import '../routes.dart';

import '../widgets/recorder_modes/mode_1_classic.dart';
import '../widgets/recorder_modes/mode_2_rounded.dart';
import '../widgets/recorder_modes/mode_3_segmented.dart';
import '../widgets/recorder_modes/mode_4_playful.dart';

// ═══════════════════════════════════════════════════════════
//  RecorderScreen
// ═══════════════════════════════════════════════════════════

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen>
    with TickerProviderStateMixin {
  // ── Audio ────────────────────────────────────────────────
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  int _level = 0;      // 0..100 raw
  int _peakLevel = 0;  // session peak
  Timer? _meterTimer;

  // ── Settings ─────────────────────────────────────────────
  AppSettings _settings = AppSettings.defaults();
  bool _settingsLoaded = false;

  // ── Active profile ───────────────────────────────────────
  String _activePatientName = '';

  // ── Route args ───────────────────────────────────────────
  String _modeId = '1';
  Color _accent = const Color(0xFF3A86FF);

  // ── Countdown state ──────────────────────────────────────
  bool _countingDown = false;
  int _countdownValue = 0;
  Timer? _countdownTimer;

  // ── Animations ───────────────────────────────────────────
  late final AnimationController _btnPulse;
  late final AnimationController _countdownScale;
  late final AnimationController _countdownFade;

  // ── Mode meta ────────────────────────────────────────────
  static const _modeNames  = {'1':'Classic','2':'Rounded','3':'Thick Meter','4':'Playful'};
  static const _modeEmojis = {'1':'⚡','2':'✨','3':'💪','4':'🎉'};

  // ── Per-mode background gradients ────────────────────────
  List<Color> get _bgGradient => switch (_modeId) {
    '1' => [const Color(0xFF1A2A4A), const Color(0xFF0D1B2A)],
    '2' => [const Color(0xFF3A1F00), const Color(0xFF1C1000)],
    '3' => [const Color(0xFF1E0A38), const Color(0xFF0D0520)],
    '4' => [const Color(0xFF003D20), const Color(0xFF001A0D)],
    _   => [const Color(0xFF1A2A4A), const Color(0xFF0D1B2A)],
  };

  Color get _accentDark => HSLColor.fromColor(_accent)
      .withLightness(
          (HSLColor.fromColor(_accent).lightness - 0.16).clamp(0.0, 1.0))
      .toColor();

  // ── normalized 0..1 scaled to maxLevel ceiling ───────────
  // e.g. if maxLevel=10 and raw level=50/100, normalized = 0.50
  // but the mode UI shows 50% of a 10-unit scale → shown as 5/10
  // We just pass raw 0..1; maxLevel is forwarded to mode widgets
  // so they can label segments correctly.
  double get _normalized => (_level / 100.0).clamp(0.0, 1.0);

  // ── RecordConfig from quality setting ────────────────────
  RecordConfig get _recordConfig => switch (_settings.recordingQuality) {
    'high'  => const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 256000, sampleRate: 44100),
    'low'   => const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000,  sampleRate: 22050),
    _       => const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
  };

  // ════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();

    _btnPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _countdownScale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _countdownFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await SettingsService.load();

    // Read active profile name from LocalDb
    final activeId = LocalDb.getActiveProfileId();
    String patientName = '';
    if (activeId != null) {
      final profiles = LocalDb.getProfiles();
      final match = profiles.where((p) => p.id == activeId);
      if (match.isNotEmpty) {
        patientName = match.first.childName.trim();
      }
    }

    if (mounted) setState(() {
      _settings = s;
      _settingsLoaded = true;
      _activePatientName = patientName;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _modeId = (args['modeId'] ?? '1').toString();
      if (args['accent'] is Color) _accent = args['accent'] as Color;
    }
  }

  @override
  void dispose() {
    _meterTimer?.cancel();
    _countdownTimer?.cancel();
    _btnPulse.dispose();
    _countdownScale.dispose();
    _countdownFade.dispose();
    _recorder.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════
  //  Countdown → then start recording
  // ════════════════════════════════════════════════════════

  Future<void> _handleStartTap() async {
    if (_isRecording || _countingDown) return;

    final secs = _settings.countdownSeconds;
    if (secs == 0) {
      _startRecording();
      return;
    }

    // Begin countdown
    setState(() {
      _countingDown = true;
      _countdownValue = secs;
    });
    _countdownFade.forward(from: 0);
    _countdownScale.forward(from: 0);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) { t.cancel(); return; }

      // Animate out then update number
      await _countdownScale.reverse();

      final next = _countdownValue - 1;
      if (!mounted) { t.cancel(); return; }

      if (next <= 0) {
        t.cancel();
        setState(() { _countingDown = false; _countdownValue = 0; });
        await _countdownFade.reverse();
        _startRecording();
      } else {
        setState(() => _countdownValue = next);
        _countdownScale.forward(from: 0);
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownFade.reverse();
    setState(() { _countingDown = false; _countdownValue = 0; });
  }

  // ════════════════════════════════════════════════════════
  //  Recording
  // ════════════════════════════════════════════════════════

  Future<void> _startRecording() async {
    final ok = await _recorder.hasPermission();
    if (!ok) {
      if (!mounted) return;
      _showSnack('Microphone permission denied ❌', const Color(0xFFFF6B6B));
      return;
    }

    final dir  = await getApplicationDocumentsDirectory();
    final name = 'rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final path = p.join(dir.path, name);

    await _recorder.start(_recordConfig, path: path);

    setState(() { _isRecording = true; _level = 0; _peakLevel = 0; });

    _startMeterLoop();
  }

  Future<void> _stopRecordingAndSave() async {
    _meterTimer?.cancel();
    _meterTimer = null;

    final path = await _recorder.stop();
    setState(() { _isRecording = false; _level = 0; });
    if (path == null) return;

    final item = RecordingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: path,
      createdAt: DateTime.now(),
      modeId: _modeId,
      level: _peakLevel,
      profileId: LocalDb.getActiveProfileId() ?? '',
    );

    await LocalDb.addRecording(item);
    if (!mounted) return;

    _showSnack('Recording saved! ✅', const Color(0xFF2ECC71));
    Navigator.pushNamed(context, AppRoutes.recordings);
  }

  void _startMeterLoop() {
    _meterTimer?.cancel();
    _meterTimer = Timer.periodic(const Duration(milliseconds: 150), (_) async {
      if (!_isRecording || !mounted) return;
      try {
        final amp = await _recorder.getAmplitude();
        final raw = ((amp.current + 60) * 1.6).clamp(0, 100).toInt();
        setState(() {
          _level = raw;
          if (_level > _peakLevel) _peakLevel = _level;
        });
      } catch (_) {}
    });
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Text(msg,
          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
    ));
  }

  // ════════════════════════════════════════════════════════
  //  Mode view builder — passes settings down
  // ════════════════════════════════════════════════════════

  Widget _buildModeView() {
    final n = _normalized;
    final ml = _settings.maxLevel;
    switch (_modeId) {
      case '1': return Mode1ClassicView(normalized: n, accent: _accent, maxLevel: ml);
      case '2': return Mode2RoundedView(normalized: n, accent: _accent, maxLevel: ml);
      case '3': return Mode3SegmentedView(normalized: n, accent: _accent, maxLevel: ml);
      case '4': return Mode4PlayfulView(normalized: n, accent: _accent, maxLevel: ml);
      default:  return Mode1ClassicView(normalized: n, accent: _accent, maxLevel: ml);
    }
  }

  // ════════════════════════════════════════════════════════
  //  Build
  // ════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _bgGradient,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Main content ──────────────────────────────
              Column(
                children: [
                  _buildTopBar(),
                  _buildSettingsBanner(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: _settingsLoaded
                            ? _buildModeView()
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  _buildBottomControls(),
                  const SizedBox(height: 20),
                ],
              ),

              // ── Countdown overlay ─────────────────────────
              if (_countingDown)
                _CountdownOverlay(
                  value: _countdownValue,
                  scaleCtrl: _countdownScale,
                  fadeCtrl: _countdownFade,
                  accent: _accent,
                  onCancel: _cancelCountdown,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          _GlassIconBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              if (_countingDown) _cancelCountdown();
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _modeNames[_modeId] ?? 'Recorder',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.4),
              ),
              // Patient name shown here
              if (_activePatientName.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _accent.withOpacity(0.40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👤', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 4),
                      Text(
                        _activePatientName,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _accent),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  'Mode $_modeId  ${_modeEmojis[_modeId] ?? ''}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.45)),
                ),
            ],
          ),
          const Spacer(),
          _PeakBadge(peakLevel: _peakLevel, maxLevel: _settings.maxLevel, accent: _accent),
        ],
      ),
    );
  }

  // ── Settings banner (shows active settings at a glance) ─
  Widget _buildSettingsBanner() {
    if (!_settingsLoaded) return const SizedBox.shrink();

    final qualityLabel = switch (_settings.recordingQuality) {
      'high' => '🎯 High',
      'low'  => '🔋 Low',
      _      => '⚖️ Medium',
    };
    final countdownLabel = _settings.countdownSeconds == 0
        ? '⚡ No delay'
        : '⏱ ${_settings.countdownSeconds}s';
    final maxLabel = '📊 Max ${_settings.maxLevel}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BannerChip(label: qualityLabel),
            _BannerDivider(),
            _BannerChip(label: countdownLabel),
            _BannerDivider(),
            _BannerChip(label: maxLabel),
            _BannerDivider(),
            _BannerChip(
              label: _settings.soundEffects ? '🔊 SFX On' : '🔇 SFX Off',
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom controls ──────────────────────────────────────
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          children: [
            // Start
            Expanded(
              child: _ActionBtn(
                label: 'Start',
                icon: Icons.mic_rounded,
                enabled: !_isRecording && !_countingDown,
                color: const Color(0xFF2ECC71),
                shadowColor: const Color(0xFF1A8A4A),
                onTap: _handleStartTap,
              ),
            ),
            const SizedBox(width: 12),
            // Big center button
            _CenterMicBtn(
              isRecording: _isRecording,
              isCounting: _countingDown,
              accent: _accent,
              accentDark: _accentDark,
              pulseCtrl: _btnPulse,
              onTap: _isRecording
                  ? _stopRecordingAndSave
                  : _countingDown
                      ? _cancelCountdown
                      : _handleStartTap,
            ),
            const SizedBox(width: 12),
            // Stop & Save
            Expanded(
              child: _ActionBtn(
                label: 'Save',
                icon: Icons.save_rounded,
                enabled: _isRecording,
                color: const Color(0xFFFF6B6B),
                shadowColor: const Color(0xFFBB2222),
                onTap: _stopRecordingAndSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Countdown Overlay
// ═══════════════════════════════════════════════════════════

class _CountdownOverlay extends StatelessWidget {
  final int value;
  final AnimationController scaleCtrl;
  final AnimationController fadeCtrl;
  final Color accent;
  final VoidCallback onCancel;

  const _CountdownOverlay({
    required this.value,
    required this.scaleCtrl,
    required this.fadeCtrl,
    required this.accent,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final scaleAnim = CurvedAnimation(parent: scaleCtrl, curve: Curves.elasticOut);
    final fadeAnim  = CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut);

    return FadeTransition(
      opacity: fadeAnim,
      child: GestureDetector(
        onTap: onCancel,
        child: Container(
          color: Colors.black.withOpacity(0.72),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Countdown number
                ScaleTransition(
                  scale: scaleAnim,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accent,
                          accent.withOpacity(0.70),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.55),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: accent,
                          blurRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$value',
                        style: const TextStyle(
                          fontSize: 82,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                          shadows: [
                            Shadow(color: Colors.black38, offset: Offset(0, 4), blurRadius: 8)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Get ready…',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Cancel
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.close_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text('Cancel',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
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
//  Center Mic Button
// ═══════════════════════════════════════════════════════════

class _CenterMicBtn extends StatelessWidget {
  final bool isRecording;
  final bool isCounting;
  final Color accent;
  final Color accentDark;
  final AnimationController pulseCtrl;
  final VoidCallback onTap;

  const _CenterMicBtn({
    required this.isRecording,
    required this.isCounting,
    required this.accent,
    required this.accentDark,
    required this.pulseCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (_, __) {
        final scale = isRecording ? 1.0 + pulseCtrl.value * 0.10 : 1.0;
        final glowR = isRecording ? 16.0 + pulseCtrl.value * 16 : 0.0;

        final Color btnColor  = isCounting
            ? const Color(0xFFFFD93D)
            : isRecording
                ? const Color(0xFFFF4444)
                : accent;
        final Color btnShadow = isCounting
            ? const Color(0xFFB89A00)
            : isRecording
                ? const Color(0xFFCC0000)
                : accentDark;
        final IconData icon = isCounting
            ? Icons.close_rounded
            : isRecording
                ? Icons.stop_rounded
                : Icons.mic_rounded;

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color.lerp(btnColor, Colors.white, 0.15)!, btnColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: btnColor.withOpacity(0.55),
                    blurRadius: glowR + 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(color: btnShadow, blurRadius: 0, offset: const Offset(0, 5)),
                ],
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 32),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Peak Badge
// ═══════════════════════════════════════════════════════════

class _PeakBadge extends StatelessWidget {
  final int peakLevel;
  final int maxLevel;
  final Color accent;

  const _PeakBadge({required this.peakLevel, required this.maxLevel, required this.accent});

  @override
  Widget build(BuildContext context) {
    // Scale raw peak (0-100) to the maxLevel range
    final scaled = ((peakLevel / 100.0) * maxLevel).round();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.40), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_upward_rounded, size: 13, color: accent),
          const SizedBox(width: 4),
          Text(
            '$scaled / $maxLevel',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: accent),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Settings Banner Chip + Divider
// ═══════════════════════════════════════════════════════════

class _BannerChip extends StatelessWidget {
  final String label;
  const _BannerChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white.withOpacity(0.65),
      ),
    );
  }
}

class _BannerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 14,
      color: Colors.white.withOpacity(0.15),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Action Button (Start / Save)
// ═══════════════════════════════════════════════════════════

class _ActionBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color     = widget.enabled ? widget.color : Colors.white.withOpacity(0.10);
    final textColor = widget.enabled ? Colors.white : Colors.white.withOpacity(0.28);

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) { setState(() => _pressed = false); widget.onTap(); }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(color: widget.shadowColor, blurRadius: 0, offset: const Offset(0, 4)),
                    BoxShadow(color: widget.color.withOpacity(0.30), blurRadius: 12, offset: const Offset(0, 6)),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: textColor, size: 18),
              const SizedBox(width: 6),
              Text(widget.label,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Glass Icon Button (back)
// ═══════════════════════════════════════════════════════════

class _GlassIconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconBtn({required this.icon, required this.onTap});

  @override
  State<_GlassIconBtn> createState() => _GlassIconBtnState();
}

class _GlassIconBtnState extends State<_GlassIconBtn> {
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
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Icon(widget.icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}