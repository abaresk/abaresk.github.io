import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          bottom: BorderSide(color: AppTheme.lightGray),
        ),
      ),
      child: ConstrainedBody(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
        "Abaresk's Blog",
        style: TextStyle(
          fontFamily: 'Chancery',
          fontSize: 28,
          fontWeight: FontWeight.w300,
          color: AppTheme.textColor,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: InkWell(
        onTap: () => context.go(path),
        mouseCursor: SystemMouseCursors.click,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Source Sans 3',
            fontSize: 16,
            color: _isActive ? AppTheme.primary : AppTheme.textColor,
            decoration: TextDecoration.none,
            fontWeight: _isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
