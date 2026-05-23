import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;
import '../../theme/app_theme.dart';

class DownloadLink extends StatefulWidget {
  final String path;
  final String label;

  const DownloadLink({super.key, required this.path, required this.label});

  @override
  State<DownloadLink> createState() => _DownloadLinkState();
}

class _DownloadLinkState extends State<DownloadLink> {
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

  void _download() async {
    await FirebaseAnalytics.instance
        .logEvent(name: 'download_link', parameters: {
      'file_path': widget.path,
      'file_label': widget.label,
    });
    web.HTMLAnchorElement()
      ..href = widget.path
      ..download = widget.label
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _focused;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            _download();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: InkWell(
            onTap: _download,
            mouseCursor: SystemMouseCursors.click,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            canRequestFocus: false,
            child: Text(
              widget.label,
              style: TextStyle(
                color: AppTheme.primary,
                decoration:
                    active ? TextDecoration.underline : TextDecoration.none,
                decorationColor: AppTheme.accent,
                backgroundColor: _focused
                    ? AppTheme.primary.withValues(alpha: 0.08)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
