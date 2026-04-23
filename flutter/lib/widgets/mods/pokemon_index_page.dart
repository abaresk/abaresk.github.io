import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/post.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';
import '../layout/constrained_body.dart';
import '../layout/page_shell.dart';

class PokemonIndexPage extends StatelessWidget {
  const PokemonIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      child: ConstrainedBody(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pokémon Mods',
                style: TextStyle(
                  fontFamily: 'Athelas',
                  fontFamilyFallback: ['Georgia', 'serif'],
                  fontSize: 32,
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              FutureBuilder<List<Post>>(
                future: ContentService.instance.loadPokemonMods(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const CircularProgressIndicator();
                  }
                  final mods = snapshot.data ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: mods.map((m) => _ModCard(mod: m)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModCard extends StatefulWidget {
  final Post mod;
  const _ModCard({required this.mod});

  @override
  State<_ModCard> createState() => _ModCardState();
}

class _ModCardState extends State<_ModCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/mods/pokemon/${widget.mod.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.fromLTRB(_hovered ? 24 : 20, 8, 20, 8),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppTheme.primary,
                width: _hovered ? 3 : 1,
              ),
            ),
          ),
          child: Text(
            widget.mod.title,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
