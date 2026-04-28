import 'package:flutter/material.dart';
import '../layout/constrained_body.dart';
import '../layout/page_shell.dart';
import 'avatar_widget.dart';
import 'homepage_heading.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      child: ConstrainedBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: AvatarWidget()),
            const Center(child: HomepageHeading()),
            const SizedBox(height: 40),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
