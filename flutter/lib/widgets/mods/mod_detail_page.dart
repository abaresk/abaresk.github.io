import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/post.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';
import '../layout/constrained_body.dart';
import '../layout/page_shell.dart';
import '../common/markdown_body.dart';

class ModDetailPage extends StatelessWidget {
  final String slug;
  const ModDetailPage({super.key, required this.slug});

  Future<(Post?, String)> _loadData() async {
    final results = await Future.wait([
      ContentService.instance.loadPokemonModMeta(slug),
      ContentService.instance.loadPokemonMod(slug),
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
                child: Text('Mod not found.'),
              );
            }
            final (mod, markdown) = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mod != null) ...[
                    Text(
                      mod.title,
                      style: GoogleFonts.literata(
                        fontSize: 32,
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  BlogMarkdownBody(data: markdown),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
