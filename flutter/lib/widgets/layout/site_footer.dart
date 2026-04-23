import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;
import '../../theme/app_theme.dart';
import 'constrained_body.dart';

int _svgIconCounter = 0;

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

class _SocialLink extends StatelessWidget {
  final String label;
  final String svgPath;
  final String url;

  const _SocialLink({
    required this.label,
    required this.svgPath,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url)),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            _SvgIcon(assetPath: svgPath, size: 18),
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

class _SvgIcon extends StatefulWidget {
  final String assetPath;
  final double size;

  const _SvgIcon({required this.assetPath, this.size = 18});

  @override
  State<_SvgIcon> createState() => _SvgIconState();
}

class _SvgIconState extends State<_SvgIcon> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'svg-icon-${_svgIconCounter++}';
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (_) {
      return web.HTMLImageElement()
        ..src = '/${widget.assetPath}'
        ..style.width = '${widget.size}px'
        ..style.height = '${widget.size}px';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
