import 'package:flutter_svg/flutter_svg.dart';

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
              svgPath: 'assets/images/github.svg',
              url: 'https://github.com/abaresk',
            ),
            const SizedBox(width: 24),
            _SocialLink(
              label: 'YouTube',
              svgPath: 'assets/images/youtube.svg',
              url: 'https://www.youtube.com/channel/UCBnmj3mxWjo_iMMnUu5qUeA',
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLink extends StatefulWidget {
  final String label;
  final String svgPath;
  final String url;

  const _SocialLink({
    required this.label,
    required this.svgPath,
    required this.url,
  });

  @override
  State<_SocialLink> createState() => _SocialLinkState();
}

class _SocialLinkState extends State<_SocialLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _isHovered ? AppTheme.primary : AppTheme.textColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(widget.url)),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              SvgPicture.asset(
                widget.svgPath,
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
