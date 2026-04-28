import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';
import '../layout/constrained_body.dart';
import '../layout/page_shell.dart';
import '../common/markdown_body.dart';

class MusicPage extends StatelessWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      child: ConstrainedBody(
        child: FutureBuilder<String>(
          future: ContentService.instance.loadPage('music'),
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
                child: Text('Music not found.'),
              );
            }
            return _MusicContent(markdown: snapshot.data!);
          },
        ),
      ),
    );
  }
}

class _MusicContent extends StatelessWidget {
  final String markdown;
  const _MusicContent({required this.markdown});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Music',
            style: GoogleFonts.literata(
              fontSize: 32,
              color: AppTheme.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          BlogMarkdownBody(data: markdown),
        ],
      ),
    );
  }
}
