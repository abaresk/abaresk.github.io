import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mods',
                style: TextStyle(
                  fontFamily: 'Athelas',
                  fontFamilyFallback: ['Georgia', 'serif'],
                  fontSize: 32,
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => context.go('/mods/pokemon'),
                child: const Text(
                  'Pokémon',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
