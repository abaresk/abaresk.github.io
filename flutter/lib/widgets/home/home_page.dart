import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/post.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';
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
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            _PostList(),
          ],
        ),
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: ContentService.instance.loadPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final posts = snapshot.data ?? [];
        return Column(
          children: posts.map((p) => _PostCard(post: p)).toList(),
        );
      },
    );
  }
}

class _PostCard extends StatefulWidget {
  final Post post;
  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/posts/${widget.post.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.fromLTRB(
            _hovered ? 16 : 12,
            8,
            12,
            8,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppTheme.primary,
                width: _hovered ? 3 : 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.title,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.post.formattedDate,
                style: const TextStyle(
                  color: AppTheme.darkGray,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
