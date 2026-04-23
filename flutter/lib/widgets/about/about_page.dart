import 'package:flutter/material.dart';
import '../../services/content_service.dart';
import '../layout/constrained_body.dart';
import '../layout/page_shell.dart';
import '../common/markdown_body.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      child: ConstrainedBody(
        child: FutureBuilder<String>(
          future: ContentService.instance.loadPage('about'),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 64),
              child: BlogMarkdownBody(data: snapshot.data!),
            );
          },
        ),
      ),
    );
  }
}
