import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/post.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';
import '../common/tabbed_link_card.dart';
import '../layout/constrained_body.dart';
import '../layout/page_shell.dart';

class ModsPage extends StatelessWidget {
  const ModsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      child: ConstrainedBody(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mods',
                  style: GoogleFonts.literata(
                    fontSize: 32,
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Pokémon challenges',
                  style: GoogleFonts.literata(
                    fontSize: 18,
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Post>>(
                  future: ContentService.instance.loadPokemonMods(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SizedBox.shrink();
                    }
                    final mods = snapshot.data ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: mods
                          .map((m) => Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: TabbedLinkCard(
                                  title: m.title,
                                  route: '/mods/pokemon/${m.slug}',
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
