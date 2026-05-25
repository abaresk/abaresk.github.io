import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;
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

// A plain paragraph that contains at least one markdown link and is rendered
// with a custom inline builder so individual links can receive Tab focus.
class _LinkParagraphSegment extends _Segment {
  final String text;
  _LinkParagraphSegment(this.text);
}

final _mdLinkRe = RegExp(r'\[.+?\]\(.+?\)');

// True for markdown that starts a block-level construct (header, list,
// blockquote, thematic break). These are left for MarkdownBody.
bool _isBlockMarkdown(String para) {
  return para.startsWith('#') ||
      para.startsWith('![') ||
      para.startsWith('>') ||
      para.startsWith('- ') ||
      para.startsWith('* ') ||
      para.startsWith('+ ') ||
      RegExp(r'^\d+\.\s').hasMatch(para) ||
      para.startsWith('---') ||
      para.startsWith('===') ||
      para.startsWith('***');
}

List<_Segment> _parseSegments(String data) {
  final segments = <_Segment>[];
  int cursor = 0;
  for (final m in _specialBlockRe.allMatches(data)) {
    if (m.start > cursor) {
      segments.addAll(_expandText(data.substring(cursor, m.start)));
    }
    segments.add(_SpecialSegment(m.group(1)!, m.group(2)!.trim()));
    cursor = m.end;
  }
  if (cursor < data.length) {
    segments.addAll(_expandText(data.substring(cursor)));
  }
  return segments;
}

// Splits a raw text chunk by paragraph boundaries. Paragraphs that contain
// markdown links become _LinkParagraphSegments; the rest are re-joined into
// _TextSegments so MarkdownBody handles them normally.
List<_Segment> _expandText(String text) {
  final result = <_Segment>[];
  final paragraphs = text.split(RegExp(r'\n{2,}'));
  final textBuf = StringBuffer();

  void flushText() {
    if (textBuf.isNotEmpty) {
      result.add(_TextSegment(textBuf.toString()));
      textBuf.clear();
    }
  }

  for (final para in paragraphs) {
    final trimmed = para.trim();
    if (trimmed.isEmpty) continue;

    if (!_isBlockMarkdown(trimmed) && _mdLinkRe.hasMatch(trimmed)) {
      flushText();
      result.add(_LinkParagraphSegment(trimmed));
    } else {
      if (textBuf.isNotEmpty) textBuf.write('\n\n');
      textBuf.write(para);
    }
  }
  flushText();
  return result;
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
        if (seg is _LinkParagraphSegment) {
          return _buildLinkParagraph(seg, styleSheet);
        }

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

  Widget _buildLinkParagraph(
      _LinkParagraphSegment seg, MarkdownStyleSheet styleSheet) {
    final doc = md.Document(extensionSet: md.ExtensionSet.gitHubWeb);
    final nodes = doc.parseInline(seg.text);
    final baseStyle = styleSheet.p ?? _bodyStyle;
    final spans = _inlineNodesToSpans(nodes, baseStyle, styleSheet);
    return Padding(
      padding: styleSheet.pPadding ?? EdgeInsets.zero,
      child: Text.rich(TextSpan(children: spans, style: baseStyle)),
    );
  }

  List<InlineSpan> _inlineNodesToSpans(
      List<md.Node> nodes, TextStyle style, MarkdownStyleSheet styleSheet) {
    final spans = <InlineSpan>[];
    for (final node in nodes) {
      if (node is md.Text) {
        spans.add(TextSpan(text: node.text, style: style));
      } else if (node is md.Element) {
        spans.addAll(_inlineElementToSpans(node, style, styleSheet));
      }
    }
    return spans;
  }

  List<InlineSpan> _inlineElementToSpans(
      md.Element el, TextStyle style, MarkdownStyleSheet styleSheet) {
    switch (el.tag) {
      case 'a':
        final href = el.attributes['href'];
        final text = el.textContent;
        final linkStyle = styleSheet.a ?? style;
        return [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: SelectionContainer.disabled(
              child: _FocusableLink(text: text, href: href, style: linkStyle),
            ),
          ),
        ];
      case 'strong':
        return _inlineNodesToSpans(el.children ?? [],
            style.copyWith(fontWeight: FontWeight.bold), styleSheet);
      case 'em':
        return _inlineNodesToSpans(el.children ?? [],
            style.copyWith(fontStyle: FontStyle.italic), styleSheet);
      case 'code':
        final codeStyle =
            styleSheet.code ?? style.copyWith(fontFamily: 'monospace');
        return [TextSpan(text: el.textContent, style: codeStyle)];
      default:
        return _inlineNodesToSpans(el.children ?? [], style, styleSheet);
    }
  }

  Widget _buildSpecial(_SpecialSegment seg) {
    switch (seg.type) {
      case 'youtube':
        return YouTubeEmbed(videoId: seg.content);
      case 'audio':
        final assetPath = seg.content.replaceFirst('/assets/assets/', '');
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
      pPadding: const EdgeInsets.only(bottom: 8),
      a: bodyStyle.copyWith(
        color: AppTheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: AppTheme.accent,
      ),
      h1Padding: const EdgeInsets.only(top: 16, bottom: 16),
      h2Padding: const EdgeInsets.only(top: 8, bottom: 8),
      h3Padding: const EdgeInsets.only(top: 6, bottom: 6),
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

// Tracks how many code blocks are currently holding the overscroll lock,
// so we only set/clear the CSS property when the count crosses zero.
int _overscrollLockCount = 0;

void _acquireOverscrollLock() {
  _overscrollLockCount++;
  if (_overscrollLockCount == 1 && kIsWeb) {
    (web.document.documentElement as web.HTMLElement?)
        ?.style
        .setProperty('overscroll-behavior-x', 'contain');
  }
}

void _releaseOverscrollLock() {
  if (_overscrollLockCount <= 0) return;
  _overscrollLockCount--;
  if (_overscrollLockCount == 0 && kIsWeb) {
    (web.document.documentElement as web.HTMLElement?)
        ?.style
        .removeProperty('overscroll-behavior-x');
  }
}

class _HighlightedCodeState extends State<HighlightedCode> {
  bool _copied = false;
  final ScrollController _scrollController = ScrollController();
  bool _hovering = false;
  bool _lockHeld = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_lockHeld) {
      _releaseOverscrollLock();
      _lockHeld = false;
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _updateLock() {
    final shouldHold = _hovering &&
        _scrollController.hasClients &&
        _scrollController.position.maxScrollExtent > 0;
    if (shouldHold && !_lockHeld) {
      _acquireOverscrollLock();
      _lockHeld = true;
    } else if (!shouldHold && _lockHeld) {
      _releaseOverscrollLock();
      _lockHeld = false;
    }
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

    return MouseRegion(
      onEnter: (_) {
        _hovering = true;
        _updateLock();
      },
      onExit: (_) {
        _hovering = false;
        _updateLock();
      },
      child: Stack(
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
      ),
    );
  }
}

class _FocusableLink extends StatefulWidget {
  final String text;
  final String? href;
  final TextStyle style;

  const _FocusableLink({
    required this.text,
    required this.href,
    required this.style,
  });

  @override
  State<_FocusableLink> createState() => _FocusableLinkState();
}

class _FocusableLinkState extends State<_FocusableLink> {
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode
        .addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _open() {
    if (widget.href != null) launchUrl(Uri.parse(widget.href!));
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space)) {
          _open();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _open,
          child: Text(
            widget.text,
            style: widget.style.copyWith(
              decorationColor: _focused ? AppTheme.primary : null,
              decorationThickness: _focused ? 2.0 : null,
              backgroundColor:
                  _focused ? AppTheme.primary.withValues(alpha: 0.08) : null,
            ),
          ),
        ),
      ),
    );
  }
}
