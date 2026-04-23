import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../services/rng_service.dart';
import '../../theme/app_theme.dart';

const _alphabet = 'abcdefghijklmnopqrstuvwxyz';
const _upperAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const _greek = 'αβγδεζηθικλμνξοπρστυφχψω';
const _upperGreek = 'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ';
const _numbers = '0123456789';
const _special = '<>()[]!?#;,.áéíóúâêîôûàèìòùãõ¡£¢∞§¶•˚√∫';

final _cipherChars =
    (_alphabet + _upperAlphabet + _greek + _upperGreek + _numbers + _special)
        .split('');

const _mediumFrameDelay = 2;
const _slowFrameDelay = 3;
const _dampeningFactor = 2;

// Holiday emoticon lists — ported verbatim from home-heading.js
const _clickMedicEmoticons = ['HUMANBODY NETWORK NAVIGATOR | CLICK SYSTEM 4'];
const _pokemonDayEmoticons = ['ϞϞ(๑⚈ ․̫ ⚈๑)∩', '(╯°□°)╯︵◓'];
const _aprilFoolsEmoticons = [
  '(☞ﾟ∀ﾟ)☞',
  '⫷(≧ ᵔ̃ ●ᵔ̃≦)⫸',
  '🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡 🤡',
];
const _halloweenEmoticons = ['༼ つ ❍_❍ ༽つ', '(㇏(>ᵥᵥ<)ノ)'];
const _christmasEmoticons = [
  '༝﹡˖˟ ⸜₍⁽ˊ꒳ˋ⁾₎⸝ ༝﹡˖˟',
  '-ˋˏ ༻🎄༺ ˎˏ ༻🎄༺ ˎˊ- ̤',
  '⋆(ㆆᴗㆆ)*✲ﾟ*｡⋆',
  '(╬ᇂ..ᇂ)o彡°',
];
const _normalHeadings = [
  '♫ヽ(๑╹◡╹๑)ﾉ♬',
  "Abaresk's Blog",
  "Abaresk's Blog",
  "Abaresk's Blog",
  '૮ ˆﻌˆ ა',
  "Abaresk's Blog",
  "Abaresk's Blog",
  '♫ヽ(๑╹◡╹๑)ﾉ♬',
  "Abaresk's Blog",
  "Abaresk's Blog",
  "Abaresk's Blog",
  '[+..••]',
  "Abaresk's Blog",
  "Abaresk's Blog",
  '૮ ˆﻌˆ ა',
  "Abaresk's Blog",
  "Abaresk's Blog",
  '(ㆆ_ㆆ)',
  '♫ヽ(๑╹◡╹๑)ﾉ♬',
  "Abaresk's Blog",
  "Abaresk's Blog",
  "Abaresk's Blog",
  '[+..••]',
  "Abaresk's Blog",
];

String _chooseByYear(DateTime date, List<String> list) =>
    list[(date.year - 1900) % list.length];

String _chooseByDay(DateTime date, List<String> list) =>
    list[daysSinceEpoch(date) % list.length];

String headingText(DateTime date) {
  if (date.month == 1 && date.day == 28) {
    return _chooseByYear(date, _clickMedicEmoticons);
  }
  if (date.month == 2 && date.day == 27) {
    return _chooseByYear(date, _pokemonDayEmoticons);
  }
  if (date.month == 4 && date.day == 1) {
    return _chooseByYear(date, _aprilFoolsEmoticons);
  }
  if (date.month == 10 && date.day == 31) {
    return _chooseByDay(date, _halloweenEmoticons);
  }
  if (date.month == 12 && date.day == 25) {
    return _chooseByDay(date, _christmasEmoticons);
  }
  return _chooseByDay(date, _normalHeadings);
}

class CipherHeading extends StatefulWidget {
  const CipherHeading({super.key});

  @override
  State<CipherHeading> createState() => _CipherHeadingState();
}

class _CipherHeadingState extends State<CipherHeading>
    with SingleTickerProviderStateMixin {
  late final String _targetText;
  late String _displayText;
  late final Pcg32 _rng;
  Ticker? _ticker;

  // Animation state
  late List<int> _randomIdxs;
  int _frame = 0;
  bool _animating = false;

  // Phase boundaries (in frames)
  late int _energizingEnd; // 0 .. 99  (100 frames)
  late int _slowingEnd; // 100 .. 124 (25 frames)
  late int _settlingEnd; // 125 .. settlingEnd

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _rng = Pcg32(seedFromDate(now));
    _targetText = headingText(now);
    _displayText = _targetText;

    // Port of the trigger condition from home-heading.js line 169.
    // The original has a parenthesis bug causing cipher to always run on
    // Jan 28. Intended logic: run on Jan 28, or 1-in-68 chance otherwise.
    final runAnimation =
        (now.month == 1 && now.day == 28) || _rng.next32() % 68 == 0;

    if (runAnimation) {
      _randomIdxs = List.generate(_targetText.length, (i) => i);
      final settlingFrames =
          _targetText.length * _slowFrameDelay * _dampeningFactor;
      _energizingEnd = 100;
      _slowingEnd = 125;
      _settlingEnd = 125 + settlingFrames;

      _animating = true;
      _ticker = createTicker(_onTick)..start();
    }
  }

  void _onTick(Duration _) {
    if (!_animating) return;

    final f = _frame;
    _frame++;

    if (f < _energizingEnd) {
      // All characters random every frame
      setState(() => _displayText = _cipherText(_randomIdxs));
    } else if (f < _slowingEnd) {
      // Slow phase: update every MEDIUM_FRAME_DELAY frames
      if ((f - _energizingEnd) % _mediumFrameDelay == 0) {
        setState(() => _displayText = _cipherText(_randomIdxs));
      }
    } else if (f < _settlingEnd) {
      final localF = f - _slowingEnd;
      // Only update every SLOW_FRAME_DELAY frames
      if (localF % _slowFrameDelay == 0 && _randomIdxs.isNotEmpty) {
        // Every SLOW_FRAME_DELAY * DAMPENING_FACTOR frames, drop one index
        if (localF % (_slowFrameDelay * _dampeningFactor) == 0) {
          final removeAt = _rng.next32() % _randomIdxs.length;
          _randomIdxs.removeAt(removeAt);
        }
        setState(() => _displayText = _cipherText(_randomIdxs));
      }
    } else {
      // Done
      _animating = false;
      _ticker?.stop();
      setState(() => _displayText = _targetText);
    }
  }

  String _cipherText(List<int> randomIdxs) {
    final idxSet = randomIdxs.toSet();
    final chars = <String>[];
    for (var i = 0; i < _targetText.length; i++) {
      if (idxSet.contains(i)) {
        chars.add(_cipherChars[_rng.next32() % _cipherChars.length]);
      } else {
        chars.add(_targetText[i]);
      }
    }
    return chars.join();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        _displayText,
        style: const TextStyle(
          fontFamily: 'Athelas',
          fontFamilyFallback: ['Georgia', 'serif'],
          fontSize: 32,
          color: AppTheme.textColor,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
