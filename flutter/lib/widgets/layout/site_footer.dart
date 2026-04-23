import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import 'constrained_body.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.lightGray),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ConstrainedBody(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialLink(
              label: 'GitHub',
              icon: Icons.code,
              url: 'https://github.com/abaresk',
            ),
            const SizedBox(width: 24),
            _SocialLink(
              label: 'YouTube',
              icon: Icons.play_circle_outline,
              url:
                  'https://www.youtube.com/channel/UCBnmj3mxWjo_iMMnUu5qUeA',
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLink extends StatelessWidget {
  final String label;
  final IconData icon;
  final String url;

  const _SocialLink({
    required this.label,
    required this.icon,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url)),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.darkGray),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
