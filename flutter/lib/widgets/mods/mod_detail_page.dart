import 'package:flutter/material.dart';
import '../../services/content_service.dart';
import '../layout/constrained_body.dart';
import '../layout/page_shell.dart';
import '../common/markdown_body.dart';

class ModDetailPage extends StatelessWidget {
  final String slug;
  const ModDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      child: ConstrainedBody(
        child: FutureBuilder<String>(
          future: ContentService.instance.loadPokemonMod(slug),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.all(48),
                child: Text('Mod not found.'),
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
