import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '../../theme/app_theme.dart';

class DownloadLink extends StatelessWidget {
  final String path;
  final String label;

  const DownloadLink({super.key, required this.path, required this.label});

  void _download() {
    web.HTMLAnchorElement()
      ..href = path
      ..download = label
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: _download,
        mouseCursor: SystemMouseCursors.click,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.primary,
            decoration: TextDecoration.underline,
            decorationColor: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
