import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/recording_item.dart';
import '../services/share_service.dart';

class RecordingDetailsScreen extends StatefulWidget {
  const RecordingDetailsScreen({super.key});

  @override
  State<RecordingDetailsScreen> createState() => _RecordingDetailsScreenState();
}

class _RecordingDetailsScreenState extends State<RecordingDetailsScreen> {
  final AudioPlayer _player = AudioPlayer();

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _state = PlayerState.stopped;

  RecordingItem? _item;

  bool get _isPlaying => _state == PlayerState.playing;

  @override
  void initState() {
    super.initState();

    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d);
    });

    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
    });

    _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _state = s);
    });

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() => _position = Duration.zero);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    final item = args is Map
        ? RecordingItem.fromJson(Map<String, dynamic>.from(args))
        : null;

    _item = item;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    final item = _item;
    if (item == null) return;

    final f = File(item.filePath);
    if (!f.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File missing ❌')),
      );
      return;
    }

    // لو واقف على جزء، كمل من نفس المكان
    await _player.play(DeviceFileSource(item.filePath), position: _position);
  }

  Future<void> _pause() async => _player.pause();

  Future<void> _stop() async {
    await _player.stop();
    if (!mounted) return;
    setState(() => _position = Duration.zero);
  }

  Future<void> _seekTo(double seconds) async {
    final d = Duration(seconds: seconds.toInt());
    await _player.seek(d);
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final mm = two(d.inMinutes.remainder(60));
    final ss = two(d.inSeconds.remainder(60));
    return '$mm:$ss';
    // لو عايز ساعات: أضيفها لك
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;

    if (item == null) {
      return const Scaffold(body: Center(child: Text('No data')));
    }

    final maxSeconds = _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0;
    final posSeconds = _position.inSeconds.clamp(0, _duration.inSeconds).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Recording Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text('Level: ${item.level}/10 • Mode ${item.modeId}'),
                subtitle: Text(item.filePath),
              ),
            ),

            const SizedBox(height: 16),

            // Playback UI
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(_isPlaying ? Icons.volume_up : Icons.volume_mute),
                        const SizedBox(width: 10),
                        Text('${_fmt(_position)} / ${_fmt(_duration)}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: posSeconds,
                      min: 0,
                      max: maxSeconds,
                      onChanged: (v) => _seekTo(v),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isPlaying ? _pause : _play,
                            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                            label: Text(_isPlaying ? 'Pause' : 'Play'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _stop,
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ShareService.shareAudioFile(item.filePath),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final f = File(item.filePath);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(f.existsSync() ? 'File exists ✅' : 'File missing ❌')),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Check File'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
