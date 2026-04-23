import 'package:flutter/material.dart';
import 'site_header.dart';
import 'site_footer.dart';

class PageShell extends StatelessWidget {
  final Widget child;

  const PageShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SiteHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  child,
                  const SiteFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
