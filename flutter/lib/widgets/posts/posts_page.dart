import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/post.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';
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
                  children: posts.map((p) => _ArchiveCard(post: p)).toList(),
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

class _ArchiveCard extends StatefulWidget {
  final Post post;
  const _ArchiveCard({required this.post});

  @override
  State<_ArchiveCard> createState() => _ArchiveCardState();
}

class _ArchiveCardState extends State<_ArchiveCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/posts/${widget.post.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.fromLTRB(_hovered ? 24 : 20, 8, 20, 8),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _hovered ? AppTheme.primary : AppTheme.textColor,
                width: _hovered ? 3 : 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.post.title,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
