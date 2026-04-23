import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import 'youtube_embed.dart';
import 'audio_player_widget.dart';
import 'download_link.dart';

class BlogMarkdownBody extends StatelessWidget {
  final String data;

  const BlogMarkdownBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      styleSheet: _buildStyleSheet(context),
      extensionSet: md.ExtensionSet.gitHubWeb,
      builders: {
        'youtube': _YouTubeBuilder(),
        'audio': _AudioBuilder(),
        'download': _DownloadBuilder(),
        'code': _CodeBlockBuilder(),
      },
      blockSyntaxes: const [
        _CustomBlockSyntax(),
      ],
      sizedImageBuilder: (config) {
        final path = config.uri.toString();
        if (path.startsWith('/')) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Image.asset('assets/content$path'),
          );
        }
        return Image.network(path);
      },
      onTapLink: (text, href, title) {
        if (href != null) launchUrl(Uri.parse(href));
      },
    );
  }

  MarkdownStyleSheet _buildStyleSheet(BuildContext context) {
    const bodyStyle = TextStyle(
      fontFamily: 'Source Sans 3',
      fontSize: 16,
      color: AppTheme.textColor,
      height: 1.6,
    );
    const codeStyle = TextStyle(
      fontFamily: 'Consolas',
      fontFamilyFallback: ['Monaco', 'Menlo', 'monospace'],
      fontSize: 14,
      color: AppTheme.codeForeground,
      backgroundColor: AppTheme.codeBackground,
    );

    return MarkdownStyleSheet(
      p: bodyStyle,
      h1: const TextStyle(
        fontFamily: 'Athelas',
        fontFamilyFallback: ['Georgia', 'serif'],
        fontSize: 26,
        color: AppTheme.textColor,
        fontWeight: FontWeight.w400,
      ),
      h2: const TextStyle(
        fontFamily: 'Athelas',
        fontFamilyFallback: ['Georgia', 'serif'],
        fontSize: 24,
        color: AppTheme.textColor,
        fontWeight: FontWeight.w400,
      ),
      h3: const TextStyle(
        fontFamily: 'Athelas',
        fontFamilyFallback: ['Georgia', 'serif'],
        fontSize: 20,
        color: AppTheme.textColor,
        fontWeight: FontWeight.w400,
      ),
      h4: const TextStyle(fontSize: 16, color: AppTheme.textColor),
      code: codeStyle,
      codeblockDecoration: BoxDecoration(
        color: AppTheme.codeBackground,
        borderRadius: BorderRadius.circular(3),
      ),
      blockquoteDecoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Color(0x4DC05B4D), // primary at 30%
            width: 3,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.primary,
            width: 2,
            style: BorderStyle.none, // dashed not supported, use solid
          ),
        ),
      ),
      a: const TextStyle(
        color: AppTheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: AppTheme.primary,
      ),
    );
  }
}

// Custom syntax that recognizes our transformed shortcode tokens:
//   [youtube:ID], [audio:PATH], [download:PATH|LABEL]
class _CustomBlockSyntax extends md.BlockSyntax {
  const _CustomBlockSyntax();

  @override
  RegExp get pattern => RegExp(r'^\[(youtube|audio|download):(.+?)\]$');

  @override
  md.Node? parse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content);
    if (match == null) {
      parser.advance();
      return null;
    }
    parser.advance();
    final tag = match.group(1)!;
    final value = match.group(2)!;
    final el = md.Element(tag, [md.Text(value)]);
    return el;
  }
}

class _YouTubeBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final videoId = element.textContent.trim();
    return YouTubeEmbed(videoId: videoId);
  }
}

class _AudioBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final path = element.textContent.trim();
    // path from content: "/music/surf.wav" → asset: "audio/surf.wav"
    final assetPath = path.replaceFirst('/music/', 'audio/');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: AudioPlayerWidget(assetPath: assetPath),
    );
  }
}

class _DownloadBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final raw = element.textContent.trim();
    final parts = raw.split('|');
    final path = parts[0];
    final label = parts.length > 1 ? parts[1] : path.split('/').last;
    return DownloadLink(path: path, label: label);
  }
}

// Handles fenced code blocks with syntax highlighting.
// Inline code (no class attribute) falls through to the stylesheet style.
class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final className = element.attributes['class'];
    if (className == null) return null; // inline code — use stylesheet
    final language = className.startsWith('language-')
        ? className.substring(9)
        : className;
    return HighlightedCode(
      code: element.textContent,
      language: language.isEmpty ? null : language,
    );
  }
}

// Syntax-highlighted code block widget.
class HighlightedCode extends StatelessWidget {
  final String code;
  final String? language;

  const HighlightedCode({super.key, required this.code, this.language});

  @override
  Widget build(BuildContext context) {
    return HighlightView(
      code,
      language: language ?? 'plaintext',
      theme: AppTheme.solarizedTheme,
      padding: const EdgeInsets.all(12),
      textStyle: const TextStyle(
        fontFamily: 'Consolas',
        fontFamilyFallback: ['Monaco', 'Menlo', 'monospace'],
        fontSize: 13.5,
        height: 1.5,
      ),
    );
  }
}
