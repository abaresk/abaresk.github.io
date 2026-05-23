import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _focused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(
        () => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _focused;
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space)) {
          context.go(widget.route);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => context.go(widget.route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: EdgeInsets.fromLTRB(active ? 24 : 20, 8, 20, 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: active ? AppTheme.primary : AppTheme.textColor,
                  width: active ? 3 : 1,
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
      ),
    );
  }
}
