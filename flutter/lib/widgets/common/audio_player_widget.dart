import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../theme/app_theme.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String assetPath;
  const AudioPlayerWidget({super.key, required this.assetPath});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final _player = AudioPlayer();
  PlayerState _state = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _state = s);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.setSourceAsset(widget.assetPath);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _state == PlayerState.playing;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border.all(color: AppTheme.lightGray),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            color: AppTheme.primary,
            onPressed: () async {
              if (isPlaying) {
                await _player.pause();
              } else {
                await _player.resume();
              }
            },
          ),
          Expanded(
            child: Slider(
              value: _duration.inMilliseconds > 0
                  ? _position.inMilliseconds / _duration.inMilliseconds
                  : 0,
              onChanged: (v) async {
                final pos = Duration(
                  milliseconds: (v * _duration.inMilliseconds).round(),
                );
                await _player.seek(pos);
              },
              activeColor: AppTheme.primary,
              inactiveColor: AppTheme.lightGray,
            ),
          ),
          Text(
            '${_format(_position)} / ${_format(_duration)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}
