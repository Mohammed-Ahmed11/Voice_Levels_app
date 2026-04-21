import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/arabic_letter.dart';
import 'package:uuid/uuid.dart';
import '../../models/recording_item.dart';
import '../../services/recorder_service.dart';
import '../../services/local_db.dart';

class ArabicLettersModeScreen extends StatefulWidget {
  const ArabicLettersModeScreen({super.key});

  @override
  State<ArabicLettersModeScreen> createState() =>
      _ArabicLettersModeScreenState();
}

class _ArabicLettersModeScreenState extends State<ArabicLettersModeScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  final RecorderService _recorderService = RecorderService();
  final _uuid = const Uuid();
  String? _currentRecordingPath;

  int? _playingIndex;
  int? _recordingIndex;
  final Set<int> _practisedLetters = {};

  late final AnimationController _bgCtrl;
  late final AnimationController _bounceCtrl;
  int _bounceTarget = -1;

  final List<ArabicLetter> letters = [
    ArabicLetter(letter: 'أ', soundPath: 'audio/arabic_letters/أ.mp3',  name: 'ألف'),
    ArabicLetter(letter: 'ب', soundPath: 'audio/arabic_letters/ب.mp3',  name: 'باء'),
    ArabicLetter(letter: 'ت', soundPath: 'audio/arabic_letters/ت.mp3',  name: 'تاء'),
    ArabicLetter(letter: 'ث', soundPath: 'audio/arabic_letters/ث.mp3',  name: 'ثاء'),
    ArabicLetter(letter: 'ج', soundPath: 'audio/arabic_letters/ج.mp3',  name: 'جيم'),
    ArabicLetter(letter: 'ح', soundPath: 'audio/arabic_letters/ح.mp3',  name: 'حاء'),
    ArabicLetter(letter: 'خ', soundPath: 'audio/arabic_letters/خ.mp3',  name: 'خاء'),
    ArabicLetter(letter: 'د', soundPath: 'audio/arabic_letters/د.mp3',  name: 'دال'),
    ArabicLetter(letter: 'ذ', soundPath: 'audio/arabic_letters/ذ.mp3',  name: 'ذال'),
    ArabicLetter(letter: 'ر', soundPath: 'audio/arabic_letters/ر.mp3',  name: 'راء'),
    ArabicLetter(letter: 'ز', soundPath: 'audio/arabic_letters/ز.mp3',  name: 'زاي'),
    ArabicLetter(letter: 'س', soundPath: 'audio/arabic_letters/س.mp3',  name: 'سين'),
    ArabicLetter(letter: 'ش', soundPath: 'audio/arabic_letters/ش.mp3',  name: 'شين'),
    ArabicLetter(letter: 'ص', soundPath: 'audio/arabic_letters/ص.mp3',  name: 'صاد'),
    ArabicLetter(letter: 'ض', soundPath: 'audio/arabic_letters/ض.mp3',  name: 'ضاد'),
    ArabicLetter(letter: 'ط', soundPath: 'audio/arabic_letters/ط.mp3',  name: 'طاء'),
    ArabicLetter(letter: 'ظ', soundPath: 'audio/arabic_letters/ظ.mp3',  name: 'ظاء'),
    ArabicLetter(letter: 'ع', soundPath: 'audio/arabic_letters/ع.mp3',  name: 'عين'),
    ArabicLetter(letter: 'غ', soundPath: 'audio/arabic_letters/غ.mp3',  name: 'غين'),
    ArabicLetter(letter: 'ف', soundPath: 'audio/arabic_letters/ف.mp3',  name: 'فاء'),
    ArabicLetter(letter: 'ق', soundPath: 'audio/arabic_letters/ق.mp3',  name: 'قاف'),
    ArabicLetter(letter: 'ك', soundPath: 'audio/arabic_letters/ك.mp3',  name: 'كاف'),
    ArabicLetter(letter: 'ل', soundPath: 'audio/arabic_letters/ل.mp3',  name: 'لام'),
    ArabicLetter(letter: 'م', soundPath: 'audio/arabic_letters/م.mp3',  name: 'ميم'),
    ArabicLetter(letter: 'ن', soundPath: 'audio/arabic_letters/ن.mp3',  name: 'نون'),
    ArabicLetter(letter: 'ه', soundPath: 'audio/arabic_letters/ه.mp3',  name: 'هاء'),
    ArabicLetter(letter: 'و', soundPath: 'audio/arabic_letters/و.mp3',  name: 'واو'),
    ArabicLetter(letter: 'ي', soundPath: 'audio/arabic_letters/ي.mp3',  name: 'ياء'),
  ];

  static const List<Color> _palette = [
    Color(0xFFFF6B6B),
    Color(0xFFFF9F1C),
    Color(0xFFFFD93D),
    Color(0xFF6BCB77),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFF9B59B6),
    Color(0xFFE91E8C),
  ];

  Color _colorFor(int index) => _palette[index % _palette.length];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _recorderService.stopRecording();
    _bgCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  Future<void> _playSound(int index) async {
    setState(() => _playingIndex = index);
    _triggerBounce(index);
    try {
      await _player.stop();
      await _player.play(AssetSource(letters[index].soundPath));
    } catch (e) {
      debugPrint('❌ Audio error: $e');
    }
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _playingIndex = null);
  }

  void _triggerBounce(int index) {
    _bounceTarget = index;
    _bounceCtrl.forward(from: 0).then((_) => _bounceCtrl.reverse());
  }

  Future<void> _startRecording(int index) async {
    final settings = LocalDb.getSettings();
    final profileId = LocalDb.getActiveProfileId();
    if (profileId == null) return;

    final filePath = await _recorderService.startRecording(
      quality: settings.recordingQuality,
    );
    if (filePath == null) return;

    _currentRecordingPath = filePath;
    setState(() {
      _recordingIndex = index;
      _practisedLetters.add(index);
    });
    _triggerBounce(index);
  }

  Future<void> _stopRecording(int index) async {
    await _recorderService.stopRecording();

    final profileId = LocalDb.getActiveProfileId();
    if (profileId == null || _currentRecordingPath == null) {
      setState(() => _recordingIndex = null);
      return;
    }

    final item = RecordingItem(
      id: _uuid.v4(),
      profileId: profileId,
      modeId: 'arabic_letters',
      level: index,
      filePath: _currentRecordingPath!,
      createdAt: DateTime.now(),
    );

    await LocalDb.addRecording(item);
    _currentRecordingPath = null;

    if (mounted) setState(() => _recordingIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _practisedLetters.length / letters.length;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(progress),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return AnimatedBuilder(
      animation: _bgCtrl,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFF16213E), const Color(0xFF0F3460), _bgCtrl.value)!,
                Color.lerp(const Color(0xFF533483), const Color(0xFF1A1A2E), _bgCtrl.value)!,
              ],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الحروف العربية',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                      Text(
                        'استمع وقلّد الحرف 🎤',
                        style: TextStyle(color: Colors.white.withOpacity(0.60), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6BCB77).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF6BCB77).withOpacity(0.45), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Text('✅ ', style: TextStyle(fontSize: 14)),
                        Text(
                          '${_practisedLetters.length}/${letters.length}',
                          style: const TextStyle(color: Color(0xFF6BCB77), fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.lerp(const Color(0xFF6BCB77), const Color(0xFFFFD93D), progress)!,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75, // ✅ FIXED: was 0.88, increased height ratio
      ),
      itemCount: letters.length,
      itemBuilder: (context, index) => _buildLetterCard(index),
    );
  }

  Widget _buildLetterCard(int index) {
    final letter = letters[index];
    final color = _colorFor(index);
    final isPlaying = _playingIndex == index;
    final isRecording = _recordingIndex == index;
    final isDone = _practisedLetters.contains(index);
    final isBouncing = _bounceTarget == index;

    return AnimatedBuilder(
      animation: _bounceCtrl,
      builder: (_, child) {
        double dy = 0;
        if (isBouncing) {
          dy = -sin(_bounceCtrl.value * pi) * 10;
        }
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: GestureDetector(
        onTap: () => _playSound(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(isPlaying || isRecording ? 0.35 : 0.18),
                color.withOpacity(0.08),
              ],
            ),
            border: Border.all(
              color: isPlaying || isRecording ? color.withOpacity(0.9) : color.withOpacity(0.30),
              width: isPlaying || isRecording ? 2.5 : 1.5,
            ),
            boxShadow: [
              if (isPlaying || isRecording)
                BoxShadow(
                  color: color.withOpacity(0.45),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          // ✅ FIXED: removed fixed padding, use Column with mainAxisSize.max naturally
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // ✅ reduced vertical padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: index + done badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isDone
                          ? Container(
                              key: const ValueKey('done'),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6BCB77).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF6BCB77), size: 18),
                            )
                          : const SizedBox(key: ValueKey('empty'), width: 26),
                    ),
                  ],
                ),

                // Big Arabic letter
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isPlaying || isRecording ? 58 : 52, // ✅ slightly reduced font size
                    color: isPlaying || isRecording ? color : Colors.white.withOpacity(0.92),
                    shadows: [
                      Shadow(color: color.withOpacity(isPlaying || isRecording ? 0.6 : 0.2), blurRadius: 16),
                    ],
                  ),
                  child: Text(letter.letter),
                ),

                // Arabic name
                Text(
                  letter.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color.withOpacity(0.85),
                    letterSpacing: 0.5,
                  ),
                ),

                // Action buttons — ✅ no extra SizedBox above
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        icon: isPlaying ? Icons.volume_up_rounded : Icons.play_circle_fill_rounded,
                        label: isPlaying ? 'يعزف...' : 'استمع',
                        color: color,
                        active: isPlaying,
                        onTap: () => _playSound(index),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionBtn(
                        icon: isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
                        label: isRecording ? 'يسجل...' : 'قلّد',
                        color: isRecording ? const Color(0xFFFF6B6B) : const Color(0xFF6BCB77),
                        active: isRecording,
                        onTap: () => isRecording
                            ? _stopRecording(index)
                            : _startRecording(index),
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
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.25) : color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? color.withOpacity(0.70) : color.withOpacity(0.30),
            width: 1.3,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}