import 'package:abaresk_blog/engine/random/pcg.dart';
import 'package:abaresk_blog/widgets/common/text_animator/animated_text.dart';
import 'package:abaresk_blog/widgets/common/text_animator/cipher_text_animator.dart';
import 'package:abaresk_blog/widgets/common/text_animator/static_text_animator.dart';
import 'package:abaresk_blog/widgets/common/text_animator/text_animator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/rng_service.dart';
import '../../theme/app_theme.dart';

// Holiday emoticon lists.
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

class HomepageHeading extends StatefulWidget {
  const HomepageHeading({super.key});

  @override
  State<HomepageHeading> createState() => _HomepageHeadingState();
}

class _HomepageHeadingState extends State<HomepageHeading> {
  late final RandomPcg _rng;
  late final String _targetText;

  late TextAnimator _animator;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _rng = RandomPcg(seedFromDate(now));
    _targetText = _headingText(now);

    // Run on Jan 28, or otherwise 1-in-68 chance.
    //
    // Click Medic came out January 28, 1999 in Japan. 68 people are credited on
    // Click Medic.
    final runAnimation =
        (now.month == 1 && now.day == 28) || _rng.randInt(68) == 0;
    _animator = runAnimation
        ? CipherTextAnimator(targetText: _targetText, rng: _rng)
        : StaticTextAnimator(_targetText);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: AnimatedText(
        animator: _animator,
        style: GoogleFonts.literata(
          fontSize: 32,
          color: AppTheme.textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _chooseByYear(DateTime date, List<String> list) =>
    list[(date.year - 1900) % list.length];

String _chooseByDay(DateTime date, List<String> list) =>
    list[daysSinceEpoch(date) % list.length];

String _headingText(DateTime date) {
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
