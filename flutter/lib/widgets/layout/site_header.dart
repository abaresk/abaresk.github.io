import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'constrained_body.dart';

class SiteHeader extends StatelessWidget {
  const SiteHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final narrow = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.primary, width: 3),
        ),
      ),
      child: ConstrainedBody(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: narrow
            ? _NarrowHeader(location: location)
            : _WideHeader(location: location),
      ),
    );
  }
}

class _WideHeader extends StatelessWidget {
  final String location;
  const _WideHeader({required this.location});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTheme.headerHeight,
      child: Row(
        children: [
          _Logo(),
          const Spacer(),
          _NavLink(label: 'Posts', path: '/posts', location: location),
          _NavLink(label: 'Mods', path: '/mods', location: location),
          _NavLink(label: 'Music', path: '/music', location: location),
          _NavLink(label: 'About', path: '/about', location: location),
        ],
      ),
    );
  }
}

class _NarrowHeader extends StatelessWidget {
  final String location;
  const _NarrowHeader({required this.location});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _Logo(),
        const SizedBox(height: 4),
        Row(
          children: [
            _NavLink(label: 'Posts', path: '/posts', location: location),
            _NavLink(label: 'Mods', path: '/mods', location: location),
            _NavLink(label: 'Music', path: '/music', location: location),
            _NavLink(label: 'About', path: '/about', location: location),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/'),
      mouseCursor: SystemMouseCursors.click,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: const Text(
        "Abaresk",
        style: TextStyle(
          fontFamily: 'Chancery',
          fontSize: 48,
          fontWeight: FontWeight.w400,
          color: AppTheme.textColor,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final String path;
  final String location;

  const _NavLink({
    required this.label,
    required this.path,
    required this.location,
  });

  bool get _isActive => location.startsWith(path);

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.go(widget.path),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: _hovered ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              builder: (context, value, _) => Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 7),
                child: CustomPaint(
                  foregroundPainter: _UnderlinePainter(
                      progress: value, color: AppTheme.primary),
                  child: Text.rich(
                    TextSpan(
                      text: widget.label,
                      style: GoogleFonts.literata(
                        fontSize: 16,
                        color: widget._isActive
                            ? AppTheme.primary
                            : AppTheme.textColor,
                        decoration: TextDecoration.none,
                        fontWeight: widget._isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      mouseCursor: SystemMouseCursors.click,
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}

class _UnderlinePainter extends CustomPainter {
  final double progress;
  final Color color;

  const _UnderlinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final centerX = size.width / 2;
    final halfWidth = size.width / 2 * progress * 0.9;
    final y = size.height + 4;
    canvas.drawLine(
        Offset(centerX - halfWidth, y), Offset(centerX + halfWidth, y), paint);
  }

  @override
  bool shouldRepaint(_UnderlinePainter old) =>
      old.progress != progress || old.color != color;
}
