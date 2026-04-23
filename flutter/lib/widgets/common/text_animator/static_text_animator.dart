import 'package:abaresk_blog/widgets/common/text_animator/text_animator.dart';

class StaticTextAnimator implements TextAnimator {
  StaticTextAnimator(this._text);

  final String _text;

  @override
  String get text => _text;

  @override
  bool get isDone => true;

  @override
  tick(Duration delta) => _text;

  @override
  void dispose() {}
}
