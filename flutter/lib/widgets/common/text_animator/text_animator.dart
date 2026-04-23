abstract class TextAnimator {
  String get text;
  bool get isDone;

  /// Called once per ticker frame.
  tick(Duration delta);

  void dispose() {}
}
