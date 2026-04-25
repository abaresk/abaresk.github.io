import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:highlight/highlight.dart' show highlight, Node;
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';
import 'youtube_embed.dart';
import 'audio_player_widget.dart';
import 'download_link.dart';
import 'blog_image.dart';

final _bodyStyle = GoogleFonts.lato(
  fontSize: 16,
  color: AppTheme.textColor,
  height: 1.5,
  fontWeight: FontWeight.w400,
);

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
          builders: {
            'pre': _CodeBlockBuilder(),
          },
          onTapLink: (text, href, title) {
            if (href != null) {
              launchUrl(Uri.parse(href));
            }
          },
          sizedImageBuilder: (config) {
            final path = config.uri.toString();
            if (path.startsWith('/')) {
              return BlogImage(assetPath: 'assets/content$path');
            }
            return Image.network(path);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSpecial(_SpecialSegment seg) {
    switch (seg.type) {
      case 'youtube':
        return YouTubeEmbed(videoId: seg.content);
      case 'audio':
        final assetPath = seg.content.replaceFirst('/music/', 'audio/');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: AudioPlayerWidget(assetPath: assetPath),
        );
      case 'download':
        final parts = seg.content.split('|');
        final path = parts[0];
        final label = parts.length > 1 ? parts[1] : path.split('/').last;
        return DownloadLink(path: path, label: label);
      default:
        return const SizedBox.shrink();
    }
  }

  MarkdownStyleSheet _buildStyleSheet(BuildContext context) {
    final bodyStyle = _bodyStyle;
    final codeStyle = GoogleFonts.sourceCodePro(
      fontSize: 14,
      color: AppTheme.codeForeground,
      fontWeight: FontWeight.w500,
    );

    return MarkdownStyleSheet(
      p: bodyStyle,
      a: bodyStyle.copyWith(
        color: AppTheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: AppTheme.accent,
      ),
      blockSpacing: 16.0,
      h2Padding: const EdgeInsets.only(top: 16),
      h3Padding: const EdgeInsets.only(top: 8),
      h1: GoogleFonts.literata(
        fontSize: 26,
        color: AppTheme.textColor,
        fontWeight: FontWeight.w500,
      ),
      h2: GoogleFonts.literata(
        fontSize: 24,
        color: AppTheme.textColor,
        fontWeight: FontWeight.w500,
      ),
      h3: GoogleFonts.literata(
        fontSize: 20,
        color: AppTheme.textColor,
        fontWeight: FontWeight.w500,
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
    );
  }
}

// Handles fenced code blocks (registered for 'pre', which never appears for
// inline code). Extracts the language from the inner <code class="language-X">
// element; falls back to plaintext when no language is specified.
class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    md.Element? codeEl;
    for (final child in element.children ?? []) {
      if (child is md.Element && child.tag == 'code') {
        codeEl = child;
        break;
      }
    }
    final className = codeEl?.attributes['class'];
    String? language;
    if (className != null && className.startsWith('language-')) {
      final lang = className.substring('language-'.length);
      if (lang.isNotEmpty) language = lang;
    }
    return HighlightedCode(
      code: element.textContent.trim(),
      language: language,
    );
  }
}

class HighlightedCode extends StatefulWidget {
  final String code;
  final String? language;

  const HighlightedCode({super.key, required this.code, this.language});

  @override
  State<HighlightedCode> createState() => _HighlightedCodeState();
}

class _HighlightedCodeState extends State<HighlightedCode> {
  bool _copied = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<TextSpan> _convert(List<Node> nodes, Map<String, TextStyle> theme) {
    final spans = <TextSpan>[];
    var currentSpans = spans;
    final stack = <List<TextSpan>>[];

    void traverse(Node node) {
      if (node.value != null) {
        currentSpans.add(node.className == null
            ? TextSpan(text: node.value)
            : TextSpan(text: node.value, style: theme[node.className!]));
      } else if (node.children != null) {
        final tmp = <TextSpan>[];
        currentSpans
            .add(TextSpan(children: tmp, style: theme[node.className!]));
        stack.add(currentSpans);
        currentSpans = tmp;
        for (final n in node.children!) {
          traverse(n);
          if (n == node.children!.last) {
            currentSpans = stack.isEmpty ? spans : stack.removeLast();
          }
        }
      }
    }

    for (final node in nodes) {
      traverse(node);
    }
    return spans;
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 750), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.solarizedTheme;
    final rootStyle = theme['root'];
    final parsed = highlight.parse(
      widget.code.replaceAll('\t', '        '),
      language: widget.language ?? 'plaintext',
    );

    final lineCount = '\n'.allMatches(widget.code).length + 1;
    final monoStyle = GoogleFonts.sourceCodePro(
      fontSize: 13.5,
      height: 1.5,
      fontWeight: FontWeight.w500,
    );

    return Stack(
      children: [
        Container(
          width: double.infinity,
          color: AppTheme.codeBackground,
          padding: const EdgeInsets.fromLTRB(6, 12, 12, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: AppTheme.textColor.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      lineCount,
                      (i) => Text(
                        '${i + 1}'.padLeft(3),
                        style: monoStyle.copyWith(
                          color: AppTheme.textColor.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: SelectableText.rich(
                          TextSpan(
                            style: monoStyle.copyWith(
                              color:
                                  rootStyle?.color ?? const Color(0xff000000),
                            ),
                            children: _convert(parsed.nodes!, theme),
                          ),
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            onPressed: _copy,
            icon: Icon(
              _copied ? Icons.check : Icons.copy,
              size: 16,
              color: _copied
                  ? Colors.green
                  : AppTheme.codeForeground.withValues(alpha: 0.5),
            ),
            tooltip: _copied ? 'Copied!' : 'Copy',
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.codeBackground,
              minimumSize: const Size(28, 28),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
