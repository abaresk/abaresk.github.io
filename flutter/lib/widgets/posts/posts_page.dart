import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';
import '../common/tabbed_link_card.dart';
import '../layout/constrained_body.dart';
import '../layout/page_shell.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      child: ConstrainedBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            FutureBuilder<List<Post>>(
              future: ContentService.instance.loadPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final posts = snapshot.data ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: posts
                      .map(
                        (p) => Row(
                          children: [
                            Expanded(
                              child: TabbedLinkCard(
                                title: p.title,
                                route: '/posts/${p.slug}',
                              ),
                            ),
                            Text(
                              p.formattedDate,
                              style: const TextStyle(
                                color: AppTheme.darkGray,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
