import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web;
import '../../theme/app_theme.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String assetPath;
  const AudioPlayerWidget({super.key, required this.assetPath});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final _player = AudioPlayer();
  final _focusNode = FocusNode();
  final _menuController = MenuController();
  PlayerState _state = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _wasPlaying = false;
  double _speed = 1.0;

  static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  static const _seekStep = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) {
        setState(() {
          _state = s;
          if (s == PlayerState.completed) _position = _duration;
        });
      }
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
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_state == PlayerState.playing) {
      await _player.pause();
    } else {
      await _player.resume();
      await _player.setPlaybackRate(_speed);
    }
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if ((event is! KeyDownEvent && event is! KeyRepeatEvent) ||
        !_focusNode.hasPrimaryFocus) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (event is KeyDownEvent) {
        _togglePlayPause();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final to = _position + _seekStep;
      _player.seek(to < _duration ? to : _duration);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      final to = _position - _seekStep;
      final seekTo = to > Duration.zero ? to : Duration.zero;
      if (_state == PlayerState.completed) {
        setState(() => _position = seekTo);
        _player.resume().then((_) async {
          await _player.seek(seekTo);
          await _player.setPlaybackRate(_speed);
        });
      } else {
        _player.seek(seekTo);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _download() {
    final filename = widget.assetPath.split('/').last;
    web.HTMLAnchorElement()
      ..href = '/assets/${widget.assetPath}'
      ..download = filename
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _state == PlayerState.playing;
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (_, event) => _handleKeyEvent(event),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.background,
          border: Border.all(color: AppTheme.lightGray),
          borderRadius: BorderRadius.circular(64),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              color: AppTheme.primary,
              onPressed: () async {
                await _togglePlayPause();
                _focusNode.requestFocus();
              },
            ),
            Expanded(
              child: Slider(
                value: _duration.inMilliseconds > 0
                    ? _position.inMilliseconds / _duration.inMilliseconds
                    : 0,
                onChangeStart: (_) async {
                  _wasPlaying = _state == PlayerState.playing;
                  await _player.pause();
                },
                onChanged: (v) => setState(() {
                  _position = Duration(
                    milliseconds: (v * _duration.inMilliseconds).round(),
                  );
                }),
                onChangeEnd: (v) async {
                  final pos = Duration(
                    milliseconds: (v * _duration.inMilliseconds).round(),
                  );
                  await _player.seek(pos);
                  if (_wasPlaying) {
                    await _player.resume();
                    await _player.setPlaybackRate(_speed);
                  }
                },
                activeColor: AppTheme.primary,
                inactiveColor: AppTheme.lightGray,
              ),
            ),
            Text(
              '${_format(_position)} ',
              style: GoogleFonts.literata(
                  fontSize: 12,
                  color:
                      [PlayerState.playing, PlayerState.paused].contains(_state)
                          ? AppTheme.primary
                          : AppTheme.darkGray),
            ),
            Text('/ ${_format(_duration)}',
                style: GoogleFonts.literata(
                    fontSize: 12, color: AppTheme.darkGray)),
            MenuAnchor(
              controller: _menuController,
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.download, size: 18),
                  onPressed: _download,
                  child: const Text('Download'),
                ),
                SubmenuButton(
                  leadingIcon: const Icon(Icons.speed, size: 18),
                  menuChildren: _speeds
                      .map((s) => MenuItemButton(
                            onPressed: () async {
                              setState(() => _speed = s);
                              await _player.setPlaybackRate(s);
                            },
                            child: Text(
                              '${s}x',
                              style: TextStyle(
                                color: s == _speed
                                    ? AppTheme.primary
                                    : AppTheme.textColor,
                                fontWeight: s == _speed
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ))
                      .toList(),
                  child: Row(
                    children: [
                      const Text('Playback speed'),
                      const SizedBox(width: 8),
                      Text(
                        '${_speed}x',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.darkGray),
                      ),
                    ],
                  ),
                ),
              ],
              child: IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppTheme.darkGray,
                ),
                tooltip: 'More options',
                onPressed: () => _menuController.open(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
