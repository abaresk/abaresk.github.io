import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../layout/constrained_body.dart';
import '../layout/page_shell.dart';
import '../common/audio_player_widget.dart';

class MusicPage extends StatelessWidget {
  const MusicPage({super.key});

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
                'Music',
                style: TextStyle(
                  fontFamily: 'Athelas',
                  fontFamilyFallback: ['Georgia', 'serif'],
                  fontSize: 32,
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Surf theme',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              const AudioPlayerWidget(assetPath: 'audio/surf.wav'),
            ],
          ),
        ),
      ),
    );
  }
}
