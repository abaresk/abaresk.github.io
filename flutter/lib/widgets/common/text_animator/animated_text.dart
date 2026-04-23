import 'package:abaresk_blog/widgets/common/text_animator/text_animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AnimatedText extends StatefulWidget {
  const AnimatedText({
    super.key,
    required this.animator,
    required this.style,
  });

  final TextAnimator animator;
  final TextStyle style;

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late String _displayText;
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _displayText = widget.animator.text;

    if (!widget.animator.isDone) {
      _ticker = createTicker(_onTick)..start();
    }
  }

  void _onTick(Duration timer) {
    if (widget.animator.isDone) {
      _ticker?.stop();
      return;
    }

    final delta = timer - _lastTick;
    _lastTick = timer;
    setState(() {
      widget.animator.tick(delta);
      _displayText = widget.animator.text;
    });
  }

  @override
  void dispose() {
    _ticker?.dispose();
    widget.animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.style,
      textAlign: TextAlign.center,
    );
  }
}
