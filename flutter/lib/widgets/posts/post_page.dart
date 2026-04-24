import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/post.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';
import '../layout/constrained_body.dart';
import '../layout/page_shell.dart';
import '../common/markdown_body.dart';

class PostPage extends StatelessWidget {
  final String slug;
  const PostPage({super.key, required this.slug});

  Future<(Post?, String)> _loadData() async {
    final results = await Future.wait([
      ContentService.instance.loadPostMeta(slug),
      ContentService.instance.loadPost(slug),
    ]);
    return (results[0] as Post?, results[1] as String);
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      child: ConstrainedBody(
        child: FutureBuilder<(Post?, String)>(
          future: _loadData(),
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
            final (post, markdown) = snapshot.data!;
            return _PostContent(post: post, markdown: markdown);
          },
        ),
      ),
    );
  }
}

class _PostContent extends StatelessWidget {
  final Post? post;
  final String markdown;
  const _PostContent({required this.post, required this.markdown});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post != null) ...[
            Text(
              post!.title,
              style: GoogleFonts.literata(
                fontSize: 32,
                color: AppTheme.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post!.formattedDate,
              style: const TextStyle(
                color: AppTheme.darkGray,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
          ],
          BlogMarkdownBody(data: markdown),
        ],
      ),
    );
  }
}
