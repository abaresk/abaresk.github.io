import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class TabbedLinkCard extends StatefulWidget {
  final String title;
  final String route;
  const TabbedLinkCard({super.key, required this.title, required this.route});

  @override
  State<TabbedLinkCard> createState() => _TabbedLinkCardState();
}

class _TabbedLinkCardState extends State<TabbedLinkCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.fromLTRB(_hovered ? 24 : 20, 8, 20, 8),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _hovered ? AppTheme.primary : AppTheme.textColor,
                width: _hovered ? 3 : 1,
              ),
            ),
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text.rich(
              TextSpan(
                text: widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.primary,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w600,
                ),
                mouseCursor: SystemMouseCursors.click,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
