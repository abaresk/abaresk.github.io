import 'package:flutter/material.dart';
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

  void _download() {
    web.HTMLAnchorElement()
      ..href = widget.path
      ..download = widget.label
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: _download,
          mouseCursor: SystemMouseCursors.click,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          child: Text(
            widget.label,
            style: TextStyle(
              color: AppTheme.primary,
              decoration:
                  _hovered ? TextDecoration.underline : TextDecoration.none,
              decorationColor: AppTheme.accent,
            ),
          ),
        ),
      ),
    );
  }
}
