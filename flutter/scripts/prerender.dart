// ignore_for_file: avoid_print
// Run from the flutter/ directory after `flutter build web`:
//   dart run scripts/prerender.dart [https://your-base-url.com]
//
// Generates a static index.html for every route in build/web/ so that web
// crawlers (and social-media preview bots) see full semantic HTML instead of
// Flutter's canvas. Each file also loads flutter_bootstrap.js, so JS-capable
// browsers still get the full Flutter app.

import 'dart:io';
import 'dart:convert';
import 'package:markdown/markdown.dart' as md;

const _defaultBaseUrl = 'https://abaresk.com';
const _buildDir = 'build/web';
const _contentDir = 'assets/content';
const _author = 'Abaresk';

late String _baseUrl;

// ── Entry point ───────────────────────────────────────────────────────────────

void main(List<String> args) async {
  _baseUrl = (args.firstWhere(
    (a) => a.startsWith('http'),
    orElse: () => _defaultBaseUrl,
  )).replaceAll(RegExp(r'/$'), '');

  print('Pre-rendering Flutter blog for SEO...');
  print('Base URL : $_baseUrl');
  print('Output   : $_buildDir/');

  if (!Directory(_buildDir).existsSync()) {
    stderr.writeln(
        'Error: $_buildDir/ not found — run `flutter build web` first.');
    exit(1);
  }
  if (!File('$_contentDir/manifest.json').existsSync()) {
    stderr.writeln(
        'Error: manifest.json not found — run from the flutter/ directory.');
    exit(1);
  }

  final manifest = jsonDecode(
    await File('$_contentDir/manifest.json').readAsString(),
  ) as Map<String, dynamic>;

  final posts = (manifest['posts'] as List).cast<Map<String, dynamic>>();
  final pokemonMods =
      (manifest['mods']['pokemon'] as List).cast<Map<String, dynamic>>();

  await _renderHome(posts, pokemonMods);
  await _renderPostsList(posts);
  for (final post in posts) {
    await _renderPost(post);
  }
  await _renderModsList(pokemonMods);
  for (final mod in pokemonMods) {
    await _renderMod(mod);
  }
  await _renderMarkdownPage(
    mdPath: '$_contentDir/music.md',
    pageTitle: 'Music',
    urlPath: '/music',
  );
  await _renderMarkdownPage(
    mdPath: '$_contentDir/about.md',
    pageTitle: 'About',
    urlPath: '/about',
  );
  await _writeSitemap(posts, pokemonMods);
  await _writeRobotsTxt();

  final pageCount = 2 + posts.length + 1 + pokemonMods.length + 2;
  print('\nDone — $pageCount pages + sitemap.xml + robots.txt written.');
}

// ── Page renderers ────────────────────────────────────────────────────────────

Future<void> _renderHome(
  List<Map<String, dynamic>> posts,
  List<Map<String, dynamic>> mods,
) async {
  final postItems = posts
      .map((p) =>
          '    <li><a href="/posts/${p['slug']}">${_esc(p['title'] as String)}</a></li>')
      .join('\n');
  final modItems = mods
      .map((m) =>
          '    <li><a href="/mods/pokemon/${m['slug']}">${_esc(m['title'] as String)}</a></li>')
      .join('\n');

  final body = '<h1>$_author\'s Blog</h1>\n'
      '<p>Pokémon game modifications, music, and more.</p>\n'
      '<h2>Posts</h2>\n<ul>\n$postItems\n</ul>\n'
      '<h2>Mods</h2>\n<ul>\n$modItems\n</ul>';

  await _writePage(
    outPath: '$_buildDir/index.html',
    pageTitle: "$_author's Blog",
    description: 'Pokémon game modifications, music, and more.',
    urlPath: '/',
    body: body,
    ogType: 'website',
  );
}

Future<void> _renderPostsList(List<Map<String, dynamic>> posts) async {
  final items = posts.map((p) {
    final date = p['date'] as String;
    return '    <li><time datetime="$date">$date</time> — '
        '<a href="/posts/${p['slug']}">${_esc(p['title'] as String)}</a></li>';
  }).join('\n');

  await _writePage(
    outPath: '$_buildDir/posts/index.html',
    pageTitle: "Posts — $_author's Blog",
    description: 'All blog posts by $_author.',
    urlPath: '/posts',
    body: '<h1>Posts</h1>\n<ul>\n$items\n</ul>',
    ogType: 'website',
  );
}

Future<void> _renderPost(Map<String, dynamic> post) async {
  final slug = post['slug'] as String;
  final title = post['title'] as String;
  final date = post['date'] as String;
  final content = await File('$_contentDir/posts/$slug.md').readAsString();
  final contentHtml = _mdToHtml(content);

  await _writePage(
    outPath: '$_buildDir/posts/$slug/index.html',
    pageTitle: '$title — $_author\'s Blog',
    description: _extractDescription(contentHtml),
    urlPath: '/posts/$slug',
    body: '<article>\n<h1>${_esc(title)}</h1>\n'
        '<time datetime="$date">$date</time>\n$contentHtml\n</article>',
    ogType: 'article',
    ogImage: _extractFirstImage(contentHtml),
    datePublished: date,
  );
}

Future<void> _renderModsList(List<Map<String, dynamic>> mods) async {
  final mdFile = File('$_contentDir/mods/_index.md');
  final intro =
      mdFile.existsSync() ? _mdToHtml(await mdFile.readAsString()) : '';

  final items = mods
      .map((m) =>
          '    <li><a href="/mods/pokemon/${m['slug']}">${_esc(m['title'] as String)}</a></li>')
      .join('\n');

  await _writePage(
    outPath: '$_buildDir/mods/index.html',
    pageTitle: "Mods — $_author's Blog",
    description: 'Pokémon game modifications and challenges by $_author.',
    urlPath: '/mods',
    body: '<h1>Mods</h1>\n$intro\n<ul>\n$items\n</ul>',
    ogType: 'website',
  );
}

Future<void> _renderMod(Map<String, dynamic> mod) async {
  final slug = mod['slug'] as String;
  final title = mod['title'] as String;
  final date = mod['date'] as String;
  final content =
      await File('$_contentDir/mods/pokemon/$slug.md').readAsString();
  final contentHtml = _mdToHtml(content);
  final description = _extractDescription(contentHtml);

  await _writePage(
    outPath: '$_buildDir/mods/pokemon/$slug/index.html',
    pageTitle: '$title — $_author\'s Blog',
    description: description.isNotEmpty
        ? description
        : 'Pokémon game modification: ${_esc(title)}',
    urlPath: '/mods/pokemon/$slug',
    body: '<article>\n<h1>${_esc(title)}</h1>\n'
        '<time datetime="$date">$date</time>\n$contentHtml\n</article>',
    ogType: 'article',
    ogImage: _extractFirstImage(contentHtml),
    datePublished: date,
  );
}

Future<void> _renderMarkdownPage({
  required String mdPath,
  required String pageTitle,
  required String urlPath,
}) async {
  final file = File(mdPath);
  if (!file.existsSync()) {
    print('  Skipping $urlPath — $mdPath not found');
    return;
  }
  final contentHtml = _mdToHtml(await file.readAsString());
  final description = _extractDescription(contentHtml);

  await _writePage(
    outPath: '$_buildDir$urlPath/index.html',
    pageTitle: '$pageTitle — $_author\'s Blog',
    description: description,
    urlPath: urlPath,
    body: '<article>\n<h1>${_esc(pageTitle)}</h1>\n$contentHtml\n</article>',
    ogType: 'website',
  );
}

// ── HTML template ─────────────────────────────────────────────────────────────

Future<void> _writePage({
  required String outPath,
  required String pageTitle,
  required String description,
  required String urlPath,
  required String body,
  required String ogType,
  String? ogImage,
  String? datePublished,
}) async {
  final url = '$_baseUrl$urlPath';
  final image = ogImage != null
      ? (_isAbsolute(ogImage) ? ogImage : '$_baseUrl$ogImage')
      : '$_baseUrl/assets/images/avatar.png';

  final jsonLd = ogType == 'article'
      ? '{"@context":"https://schema.org","@type":"BlogPosting",'
          '"headline":"${_escJson(pageTitle)}",'
          '"datePublished":"${datePublished ?? ''}",'
          '"url":"${_escJson(url)}",'
          '"author":{"@type":"Person","name":"$_author"},'
          '"image":"${_escJson(image)}"}'
      : '{"@context":"https://schema.org","@type":"WebPage",'
          '"name":"${_escJson(pageTitle)}",'
          '"url":"${_escJson(url)}",'
          '"author":{"@type":"Person","name":"$_author"}}';

  final html = '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <base href="/">
  <title>${_esc(pageTitle)}</title>
  <meta name="description" content="${_esc(description)}">
  <link rel="canonical" href="${_esc(url)}">
  <meta property="og:title" content="${_esc(pageTitle)}">
  <meta property="og:description" content="${_esc(description)}">
  <meta property="og:url" content="${_esc(url)}">
  <meta property="og:type" content="$ogType">
  <meta property="og:image" content="${_esc(image)}">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${_esc(pageTitle)}">
  <meta name="twitter:description" content="${_esc(description)}">
  <script type="application/ld+json">$jsonLd</script>
  <link rel="icon" type="image/png" href="/favicon.png">
  <link rel="manifest" href="/manifest.json">
  <style>html { opacity: 0; transition: opacity 0.3s ease; }</style>
  <script>
    (function() {
      var t = setTimeout(function() {
        document.documentElement.style.opacity = '1';
      }, 10000);
      window.addEventListener('flutter-first-frame', function() {
        clearTimeout(t);
        document.documentElement.style.opacity = '1';
      });
    })();
  </script>
</head>
<body>
  <nav>
    <a href="/">${_esc("$_author's Blog")}</a> |
    <a href="/posts">Posts</a> |
    <a href="/mods">Mods</a> |
    <a href="/music">Music</a> |
    <a href="/about">About</a>
  </nav>
  <main>
    $body
  </main>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
''';

  await _writeFile(outPath, html);
}

// ── Markdown → HTML ───────────────────────────────────────────────────────────

final _specialBlockRe = RegExp(
  r'```(youtube|audio|download)\n([\s\S]*?)\n```',
  multiLine: true,
);

String _mdToHtml(String markdownText) {
  final buffer = StringBuffer();
  int lastEnd = 0;

  for (final match in _specialBlockRe.allMatches(markdownText)) {
    if (match.start > lastEnd) {
      buffer.write(md.markdownToHtml(
        markdownText.substring(lastEnd, match.start),
        extensionSet: md.ExtensionSet.gitHubWeb,
      ));
    }
    final type = match.group(1)!;
    final content = match.group(2)!.trim();
    switch (type) {
      case 'youtube':
        buffer.write(
            '<p><a href="https://www.youtube.com/watch?v=${_esc(content)}">'
            'Watch on YouTube</a></p>');
      case 'audio':
        buffer.write('<audio controls><source src="${_esc(content)}"></audio>');
      case 'download':
        final parts = content.split('|');
        final path = _esc(parts[0].trim());
        final label = _esc(parts.length > 1 ? parts[1].trim() : 'Download');
        buffer.write('<p><a href="$path" download>$label</a></p>');
    }
    lastEnd = match.end;
  }

  if (lastEnd < markdownText.length) {
    buffer.write(md.markdownToHtml(
      markdownText.substring(lastEnd),
      extensionSet: md.ExtensionSet.gitHubWeb,
    ));
  }

  // Rewrite asset image paths: /posts/... → /assets/content/posts/...
  var html = buffer.toString();
  html = html.replaceAllMapped(
    RegExp(r'src="(/(?:posts|mods)/[^"]+)"'),
    (m) => 'src="/assets/content${m.group(1)}"',
  );
  return html;
}

// ── Metadata extraction ───────────────────────────────────────────────────────

String _extractDescription(String html) {
  final match = RegExp(r'<p>(.*?)</p>', dotAll: true).firstMatch(html);
  if (match == null) return '';
  var text = match
      .group(1)!
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .trim();
  return text.length > 160 ? '${text.substring(0, 157)}...' : text;
}

String? _extractFirstImage(String html) {
  final match = RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(html);
  if (match == null) return null;
  final src = match.group(1)!;
  return _isAbsolute(src) ? src : '$_baseUrl$src';
}

// ── Sitemap & robots.txt ──────────────────────────────────────────────────────

Future<void> _writeSitemap(
  List<Map<String, dynamic>> posts,
  List<Map<String, dynamic>> mods,
) async {
  final buf = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');

  void addUrl(String path, {String? lastmod, String priority = '0.5'}) {
    buf.writeln('  <url>');
    buf.writeln('    <loc>$_baseUrl$path</loc>');
    if (lastmod != null) buf.writeln('    <lastmod>$lastmod</lastmod>');
    buf.writeln('    <priority>$priority</priority>');
    buf.writeln('  </url>');
  }

  addUrl('/', priority: '1.0');
  addUrl('/posts', priority: '0.8');
  for (final p in posts) {
    addUrl('/posts/${p['slug']}',
        lastmod: p['date'] as String, priority: '0.8');
  }
  addUrl('/mods', priority: '0.7');
  for (final m in mods) {
    addUrl('/mods/pokemon/${m['slug']}',
        lastmod: m['date'] as String, priority: '0.7');
  }
  addUrl('/music', priority: '0.5');
  addUrl('/about', priority: '0.5');

  buf.writeln('</urlset>');
  await _writeFile('$_buildDir/sitemap.xml', buf.toString());
}

Future<void> _writeRobotsTxt() async {
  await _writeFile(
    '$_buildDir/robots.txt',
    'User-agent: *\nAllow: /\nSitemap: $_baseUrl/sitemap.xml\n',
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Future<void> _writeFile(String path, String content) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(content);
  print('  wrote $path');
}

bool _isAbsolute(String url) =>
    url.startsWith('http://') || url.startsWith('https://');

// HTML-escape for element content and double-quote attribute values.
String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

// JSON string escaping for use inside ld+json blocks.
String _escJson(String s) => s
    .replaceAll('\\', '\\\\')
    .replaceAll('"', '\\"')
    .replaceAll('\n', '\\n')
    .replaceAll('\r', '\\r');
