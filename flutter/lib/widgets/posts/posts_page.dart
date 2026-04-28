import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                final Map<int, List<Post>> postsByYear = {};
                for (final p in posts) {
                  postsByYear.putIfAbsent(p.date.year, () => []).add(p);
                }
                final years = postsByYear.keys.toList()
                  ..sort((a, b) => b.compareTo(a));
                final widgets = <Widget>[];
                for (final year in years) {
                  widgets.add(const SizedBox(height: 24));
                  widgets.add(Text(
                    '$year',
                    style: GoogleFonts.literata(
                        fontSize: 24,
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.w500),
                  ));
                  widgets.add(const SizedBox(height: 8));
                  for (final p in postsByYear[year]!) {
                    widgets.add(Row(
                      children: [
                        Expanded(
                          child: TabbedLinkCard(
                            title: p.title,
                            route: '/posts/${p.slug}',
                          ),
                        ),
                        Text(
                          p.monthDay,
                          style: GoogleFonts.literata(
                              fontSize: 13, color: AppTheme.darkGray),
                        ),
                      ],
                    ));
                  }
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widgets,
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
