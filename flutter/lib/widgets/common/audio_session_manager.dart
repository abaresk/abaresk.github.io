import 'dart:js_interop';

import 'package:audioplayers/audioplayers.dart';
import 'package:web/web.dart' as web;

/// Implemented by widgets that can be controlled via the browser's Media
/// Session API (e.g. the macOS Play/Pause key or headphone media buttons).
abstract class AudioPlaybackController {
  void play();
  void pause();
  void stop();
}

/// Coordinates the page's single Media Session so that hardware media keys
/// (macOS Play/Pause, headphone buttons) act on whichever audio player was
/// most recently playing.
class AudioSessionManager {
  AudioSessionManager._() {
    final session = web.window.navigator.mediaSession;
    session.setActionHandler(
        'play',
        (() {
          _active?.play();
        }).toJS);
    session.setActionHandler(
        'pause',
        (() {
          _active?.pause();
        }).toJS);
    session.setActionHandler(
        'stop',
        (() {
          _active?.stop();
        }).toJS);
  }

  static final instance = AudioSessionManager._();

  AudioPlaybackController? _active;

  void setActive(AudioPlaybackController controller) {
    _active = controller;
  }

  void clearActive(AudioPlaybackController controller) {
    if (_active == controller) _active = null;
  }

  void updatePlaybackState(
      AudioPlaybackController controller, PlayerState state) {
    if (_active != controller) return;

    web.window.navigator.mediaSession.playbackState = switch (state) {
      PlayerState.playing => 'playing',
      PlayerState.paused => 'paused',
      _ => 'none',
    };
  }
}
