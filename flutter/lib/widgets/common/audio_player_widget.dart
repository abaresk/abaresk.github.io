import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web;
import '../../theme/app_theme.dart';

enum ProgressMilestone {
  p25(25),
  p50(50),
  p75(75),
  p100(100);

  final int percent;
  const ProgressMilestone(this.percent);
}

class AudioPlayerWidget extends StatefulWidget {
  final String assetPath;
  const AudioPlayerWidget({super.key, required this.assetPath});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final _player = AudioPlayer();
  final _focusNode = FocusNode();
  final _playButtonFocusNode = FocusNode();
  final _menuButtonFocusNode = FocusNode();
  final _downloadMenuItemFocusNode = FocusNode();
  final _menuController = MenuController();
  PlayerState _state = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _wasPlaying = false;
  double _speed = 1.0;
  final _loggedMilestones = <ProgressMilestone>{};

  static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  static const _seekStep = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) {
        _onPlayerStateChanged(s);
      }
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) {
        _onPositionChanged(p);
      }
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
    _playButtonFocusNode.dispose();
    _menuButtonFocusNode.dispose();
    _downloadMenuItemFocusNode.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_state == PlayerState.playing) {
      await _player.pause();
    } else {
      await FirebaseAnalytics.instance
          .logEvent(name: 'play_audio', parameters: _analyticsParams);
      await _player.resume();
      await _player.setPlaybackRate(_speed);
    }
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if ((event is! KeyDownEvent && event is! KeyRepeatEvent) ||
        !_focusNode.hasFocus) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (_menuButtonFocusNode.hasPrimaryFocus) return KeyEventResult.ignored;
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

  Map<String, Object> get _analyticsParams => {
        'file_path': '/assets/${widget.assetPath}',
        'file_label': widget.assetPath.split('/').last,
      };

  void _onPlayerStateChanged(PlayerState state) {
    setState(() {
      _state = state;
      if (state == PlayerState.completed) {
        _position = _duration;
      }
    });
  }

  void _onPositionChanged(Duration position) {
    setState(() => _position = position);
    if (_duration <= Duration.zero) return;

    final pct =
        (position.inMilliseconds / _duration.inMilliseconds * 100).round();
    for (final milestone in [
      ProgressMilestone.p25,
      ProgressMilestone.p50,
      ProgressMilestone.p75,
      ProgressMilestone.p100,
    ]) {
      if (pct >= milestone.percent && !_loggedMilestones.contains(milestone)) {
        _loggedMilestones.add(milestone);
        FirebaseAnalytics.instance
            .logEvent(name: 'audio_progress', parameters: {
          ..._analyticsParams,
          'percent': milestone.percent,
        });
      }
    }
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _download() async {
    await FirebaseAnalytics.instance
        .logEvent(name: 'download_audio', parameters: _analyticsParams);
    web.HTMLAnchorElement()
      ..href = '/assets/assets/${widget.assetPath}'
      ..download = widget.assetPath.split('/').last
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
              focusNode: _playButtonFocusNode,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              color: AppTheme.primary,
              onPressed: () async {
                await _togglePlayPause();
                _playButtonFocusNode.requestFocus();
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
                  final pct = _duration.inMilliseconds > 0
                      ? (pos.inMilliseconds / _duration.inMilliseconds * 100)
                          .round()
                      : 0;
                  _loggedMilestones.removeWhere((m) => m.percent > pct);
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
            SizedBox(
              width: 38,
              child: Text(
                _format(_position),
                textAlign: TextAlign.right,
                style: GoogleFonts.literata(
                    fontSize: 12,
                    fontFeatures: [const FontFeature.tabularFigures()],
                    color: [PlayerState.playing, PlayerState.paused]
                            .contains(_state)
                        ? AppTheme.primary
                        : AppTheme.darkGray),
              ),
            ),
            Text(' / ${_format(_duration)}',
                style: GoogleFonts.literata(
                    fontSize: 12,
                    fontFeatures: [const FontFeature.tabularFigures()],
                    color: AppTheme.darkGray)),
            MenuAnchor(
              controller: _menuController,
              childFocusNode: _menuButtonFocusNode,
              menuChildren: [
                MenuItemButton(
                  focusNode: _downloadMenuItemFocusNode,
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
                              await FirebaseAnalytics.instance.logEvent(
                                  name: 'audio_playback_speed',
                                  parameters: {
                                    ..._analyticsParams,
                                    'speed': s,
                                  });
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
                focusNode: _menuButtonFocusNode,
                icon: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppTheme.darkGray,
                ),
                tooltip: 'More options',
                onPressed: () {
                  final buttonHadFocus = _menuButtonFocusNode.hasPrimaryFocus;
                  _menuController.open();
                  if (buttonHadFocus) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _menuController.isOpen) {
                        _downloadMenuItemFocusNode.requestFocus();
                      }
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
