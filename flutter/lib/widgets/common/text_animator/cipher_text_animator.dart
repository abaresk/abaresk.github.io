import 'package:abaresk_blog/engine/random/pcg.dart';
import 'package:abaresk_blog/widgets/common/text_animator/text_animator.dart';

const _alphabet = 'abcdefghijklmnopqrstuvwxyz';
const _upperAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const _greek = 'αβγδεζηθικλμνξοπρστυφχψω';
const _upperGreek = 'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ';
const _numbers = '0123456789';
const _special = '<>()[]!?#;,.áéíóúâêîôûàèìòùãõ¡£¢∞§¶•˚√∫';
final cipherChars =
    (_alphabet + _upperAlphabet + _greek + _upperGreek + _numbers + _special)
        .split('');

// Animation settings.
const _frameMics = 1000000 ~/ 60;
const _energizingFrames = 100;
const _slowingFrames = 25;

const _mediumFrameDelay = 2;
const _slowFrameDelay = 3;
const _dampeningFactor = 3;

/// Cipher animation.
///
/// Random cipher text effect, like in Click Medic.
/// https://youtu.be/pHJ-XM9FD0I&t=770
class CipherTextAnimator implements TextAnimator {
  CipherTextAnimator({
    required this.rng,
    required this.targetText,
  })  : _randomIdxs = {
          for (var i = 0; i < targetText.length; i++) i,
        },
        _currentText = targetText;

  final RandomPcg rng;
  final String targetText;

  final Set<int> _randomIdxs;

  Duration _timer = Duration.zero;
  String _currentText;
  bool _done = false;

  static const _energizingDuration =
      Duration(microseconds: _energizingFrames * _frameMics);
  static const _slowingDuration =
      Duration(microseconds: _slowingFrames * _frameMics);
  static const _mediumDelay =
      Duration(microseconds: _mediumFrameDelay * _frameMics);
  static const _slowDelay =
      Duration(microseconds: _slowFrameDelay * _frameMics);
  static const _removeCharDelay =
      Duration(microseconds: _slowFrameDelay * _dampeningFactor * _frameMics);

  @override
  String get text => _currentText;

  @override
  bool get isDone => _done;

  void tick(Duration delta) {
    _timer += delta;

    // Energy loading animation (max speed, completely random).
    if (_timer < _energizingDuration) {
      _currentText = _cipherText();
      return;
    }

    // Slowing down (lower speed, completely random).
    final slowingElapsed = _timer - _energizingDuration;
    if (slowingElapsed < _slowingDuration) {
      if (_isIntervalFrame(slowingElapsed, _mediumDelay)) {
        _currentText = _cipherText();
      }
      return;
    }

    // Settling animation (lower speed, gradually stabilizing).
    final settlingElapsed = slowingElapsed - _slowingDuration;
    if (_randomIdxs.isNotEmpty) {
      if (_isIntervalFrame(settlingElapsed, _slowDelay)) {
        if (_isIntervalFrame(settlingElapsed, _removeCharDelay)) {
          _removeRandomIndex();
        }

        _currentText = _cipherText();
      }
      return;
    }

    _done = true;
  }

  bool _isIntervalFrame(Duration elapsed, Duration interval) {
    return elapsed.inMicroseconds % interval.inMicroseconds < _frameMics;
  }

  void _removeRandomIndex() {
    if (_randomIdxs.isEmpty) return;

    final idx = rng.randInt(_randomIdxs.length);
    _randomIdxs.remove(_randomIdxs.elementAt(idx));
  }

  String _cipherText() {
    return [
      for (var i = 0; i < targetText.length; i++)
        _randomIdxs.contains(i)
            ? cipherChars[rng.randInt(cipherChars.length)]
            : targetText[i],
    ].join();
  }

  @override
  void dispose() {}
}
