import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../models/recording_item.dart';
import '../models/app_settings.dart';
import '../models/mode_theme.dart';
import '../services/audio_level_service.dart';
import '../services/local_db.dart';
import '../services/permissions_service.dart';
import '../services/recorder_service.dart';

import '../widgets/recorder_modes/mode_1_classic.dart';
import '../widgets/recorder_modes/mode_2_rounded.dart';
import '../widgets/recorder_modes/mode_3_segmented.dart';
import '../widgets/recorder_modes/mode_4_playful.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  final _recorder = RecorderService();
  final _levels = AudioLevelService();

  late AppSettings _settings;

  double _currentLevel = 0.0; // raw 0..1 from AudioLevelService
  double _maxLevel = 0.0;

  String? _filePath;
  bool _recording = false;
  String _modeId = '1';

  int? _countdown;
  int _lastLevel = 1;

  late ModeTheme _modeTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['modeId'] != null) {
      _modeId = args['modeId'].toString();
    }
    _modeTheme = ModeTheme.fromId(_modeId);
  }

  @override
  void initState() {
    super.initState();

    _settings = LocalDb.getSettings();
    _modeTheme = ModeTheme.fromId(_modeId);

    _levels.levelStream.listen((v) {
      if (!_recording) return;

      final maxLevel = _settings.maxLevel;
      final current = AudioLevelService.toLevel(v, maxLevel: maxLevel);

      if (_settings.soundEffects && current > _lastLevel) {
        SystemSound.play(SystemSoundType.click);
      }
      _lastLevel = current;

      setState(() {
        _currentLevel = v;
        if (v > _maxLevel) _maxLevel = v;
      });
    });
  }

  Future<void> _runCountdownIfNeeded() async {
    final seconds = _settings.countdownSeconds;
    if (seconds <= 0) return;

    setState(() => _countdown = seconds);

    for (int s = seconds; s >= 1; s--) {
      setState(() => _countdown = s);
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() => _countdown = null);
  }

  Future<void> _start() async {
    _settings = LocalDb.getSettings();

    final ok = await PermissionsService.ensureAudioPermissions();
    debugPrint("MIC PERMISSION: $ok");

    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
      }
      return;
    }

    await _runCountdownIfNeeded();

    final path = await _recorder.startRecording(quality: _settings.recordingQuality);
    debugPrint("Recording path: $path");

    if (path == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission not granted (record plugin)')),
        );
      }
      return;
    }

    _filePath = path;
    _levels.start();

    setState(() {
      _recording = true;
      _currentLevel = 0;
      _maxLevel = 0;
      _lastLevel = 1;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording started ✅ (${_settings.recordingQuality})')),
      );
    }
  }

  Future<void> _stopAndSave() async {
    _levels.stop();
    await _recorder.stopRecording();

    final maxLevel = _settings.maxLevel;
    final finalLevel = AudioLevelService.toLevel(_maxLevel, maxLevel: maxLevel);

    if (_filePath != null) {
      final item = RecordingItem(
        id: const Uuid().v4(),
        filePath: _filePath!,
        createdAt: DateTime.now(),
        level: finalLevel,
        modeId: _modeId,
      );
      await LocalDb.addRecording(item);
    }

    setState(() {
      _recording = false;
      _countdown = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved ✅ - Level: $finalLevel/$maxLevel')),
      );
    }
  }

  @override
  void dispose() {
    _levels.dispose();
    super.dispose();
  }

  Widget _buildModeWidget(double normalized) {
    switch (_modeId) {
      case '1':
        return Mode1ClassicView(normalized: normalized, accent: _modeTheme.accent);
      case '2':
        return Mode2RoundedView(normalized: normalized, accent: _modeTheme.accent);
      case '3':
        return Mode3SegmentedView(normalized: normalized, accent: _modeTheme.accent, segments: _settings.maxLevel);
      case '4':
        return Mode4PlayfulView(normalized: normalized, accent: _modeTheme.accent);
      default:
        return Mode1ClassicView(normalized: normalized, accent: _modeTheme.accent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxLevel = _settings.maxLevel;
    final liveLevelNumber = AudioLevelService.toLevel(_currentLevel, maxLevel: maxLevel);

    // normalized 0..1
    final normalized = _currentLevel.clamp(0.0, 1.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Recorder (${_modeTheme.title})'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_modeTheme.backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(_modeTheme.overlayOpacity),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  if (_countdown != null) ...[
                    Text(
                      'Starting in $_countdown...',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Text(
                    _recording ? 'Speak Now…' : 'Press Start to Record',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ✅ different design per mode
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.20)),
                        ),
                        child: Column(
                          children: [
                            _buildModeWidget(normalized),
                            const SizedBox(height: 10),
                            Text(
                              'Live Level: $liveLevelNumber / $maxLevel',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          _recording ? Icons.mic : Icons.mic_none,
                          key: ValueKey(_recording),
                          size: 120,
                          color: _modeTheme.accent.withOpacity(0.95),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.18),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: (_recording || _countdown != null) ? null : _start,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _modeTheme.accent.withOpacity(0.35),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _recording ? _stopAndSave : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop & Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
