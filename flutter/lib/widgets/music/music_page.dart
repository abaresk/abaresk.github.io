import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
              Text(
                'Music',
                style: GoogleFonts.literata(
                  fontSize: 32,
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Surf theme',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              const AudioPlayerWidget(assetPath: 'audio/surf.wav'),
            ],
          ),
        ),
      ),
    );
  }
}
