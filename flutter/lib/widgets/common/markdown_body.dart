import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import 'youtube_embed.dart';
import 'audio_player_widget.dart';
import 'download_link.dart';
import 'blog_image.dart';

// Matches fenced code blocks that carry media/download tokens.
final _specialBlockRe = RegExp(
  r'```(youtube|audio|download)\n([\s\S]*?)\n```',
  multiLine: true,
);

sealed class _Segment {}

class _TextSegment extends _Segment {
  final String text;
  _TextSegment(this.text);
}

class _SpecialSegment extends _Segment {
  final String type;
  final String content;
  _SpecialSegment(this.type, this.content);
}

List<_Segment> _parseSegments(String data) {
  final segments = <_Segment>[];
  int cursor = 0;
  for (final m in _specialBlockRe.allMatches(data)) {
    if (m.start > cursor) {
      segments.add(_TextSegment(data.substring(cursor, m.start)));
    }
    segments.add(_SpecialSegment(m.group(1)!, m.group(2)!.trim()));
    cursor = m.end;
  }
  if (cursor < data.length) {
    segments.add(_TextSegment(data.substring(cursor)));
  }
  return segments;
}

class BlogMarkdownBody extends StatelessWidget {
  final String data;

  const BlogMarkdownBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final segments = _parseSegments(data);
    final styleSheet = _buildStyleSheet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((seg) {
        if (seg is _SpecialSegment) return _buildSpecial(seg);

        final text = (seg as _TextSegment).text;
        if (text.trim().isEmpty) return const SizedBox.shrink();

        return MarkdownBody(
          data: text,
          styleSheet: styleSheet,
          extensionSet: md.ExtensionSet.gitHubWeb,
          builders: {'code': _CodeBlockBuilder()},
          sizedImageBuilder: (config) {
            final path = config.uri.toString();
            if (path.startsWith('/')) {
              return BlogImage(assetPath: 'assets/content$path');
            }
            return Image.network(path);
          },
          onTapLink: (text, href, title) {
            if (href != null) launchUrl(Uri.parse(href));
          },
        );
      }).toList(),
    );
  }

  Widget _buildSpecial(_SpecialSegment seg) {
    switch (seg.type) {
      case 'youtube':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: YouTubeEmbed(videoId: seg.content),
        );
      case 'audio':
        final assetPath = seg.content.replaceFirst('/music/', 'audio/');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: AudioPlayerWidget(assetPath: assetPath),
        );
      case 'download':
        final parts = seg.content.split('|');
        final path = parts[0];
        final label =
            parts.length > 1 ? parts[1] : path.split('/').last;
        return DownloadLink(path: path, label: label);
      default:
        return const SizedBox.shrink();
    }
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
          left: BorderSide(color: Color(0x4DC05B4D), width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
      a: const TextStyle(
        color: AppTheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: AppTheme.primary,
      ),
    );
  }
}

// Syntax highlighting for real code blocks inside MarkdownBody segments.
// Inline code (no class attribute) falls through to the stylesheet style.
class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final className = element.attributes['class'];
    if (className == null) return null;
    final language = className.startsWith('language-')
        ? className.substring(9)
        : className;
    return HighlightedCode(
      code: element.textContent.trim(),
      language: language.isEmpty ? null : language,
    );
  }
}

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
