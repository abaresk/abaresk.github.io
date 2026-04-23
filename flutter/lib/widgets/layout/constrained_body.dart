import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ConstrainedBody extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ConstrainedBody({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          child: child,
        ),
      ),
    );
  }
}
