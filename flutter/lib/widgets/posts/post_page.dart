import 'package:flutter/material.dart';
import '../../services/content_service.dart';
import '../layout/constrained_body.dart';
import '../layout/page_shell.dart';
import '../common/markdown_body.dart';

class PostPage extends StatelessWidget {
  final String slug;
  const PostPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      child: ConstrainedBody(
        child: FutureBuilder<String>(
          future: ContentService.instance.loadPost(slug),
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
                child: Text('Post not found.'),
              );
            }
            return _PostContent(markdown: snapshot.data!);
          },
        ),
      ),
    );
  }
}

class _PostContent extends StatelessWidget {
  final String markdown;
  const _PostContent({required this.markdown});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          BlogMarkdownBody(data: markdown),
        ],
      ),
    );
  }
}
