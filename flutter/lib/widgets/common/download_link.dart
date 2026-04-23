import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class DownloadLink extends StatelessWidget {
  final String path;
  final String label;

  const DownloadLink({super.key, required this.path, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(path)),
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
