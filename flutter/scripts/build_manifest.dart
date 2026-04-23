// Run with: dart run scripts/build_manifest.dart
// Reads Hugo content/ files, transforms shortcodes, writes to flutter/assets/content/
// and generates flutter/assets/content/manifest.json

import 'dart:io';
import 'dart:convert';
import 'package:yaml/yaml.dart';

final contentRoot = '../content';
final outputRoot = 'assets/content';

void main() async {
  final manifest = <String, dynamic>{
    'posts': <Map<String, dynamic>>[],
    'mods': {
      'pokemon': <Map<String, dynamic>>[],
    },
  };

  // Process posts/
  final postsDir = Directory('$contentRoot/posts');
  if (postsDir.existsSync()) {
    for (final file in postsDir.listSync().whereType<File>()) {
      if (!file.path.endsWith('.md')) continue;
      final slug = file.uri.pathSegments.last.replaceAll('.md', '');
      final info = await processFile(file, '$outputRoot/posts/$slug.md');
      if (info != null) {
        (manifest['posts'] as List).add({
          'slug': slug,
          'title': info['title'],
          'date': info['date'],
        });
      }
    }
    // Sort by date descending
    (manifest['posts'] as List).sort((a, b) =>
        (b['date'] as String).compareTo(a['date'] as String));
  }

  // Process mods/pokemon/
  final pokemonDir = Directory('$contentRoot/mods/pokemon');
  if (pokemonDir.existsSync()) {
    for (final file in pokemonDir.listSync().whereType<File>()) {
      if (!file.path.endsWith('.md')) continue;
      final slug = file.uri.pathSegments.last.replaceAll('.md', '');
      final outPath = '$outputRoot/mods/pokemon/$slug.md';
      final info = await processFile(file, outPath);
      if (info != null && slug != '_index') {
        (manifest['mods']['pokemon'] as List).add({
          'slug': slug,
          'title': info['title'],
          'date': info['date'],
        });
      }
    }
    (manifest['mods']['pokemon'] as List).sort((a, b) =>
        (b['date'] as String).compareTo(a['date'] as String));
  }

  // Process mods/_index.md
  await processFile(
    File('$contentRoot/mods/_index.md'),
    '$outputRoot/mods/_index.md',
  );

  // Process about.md and music.md
  await processFile(File('$contentRoot/about.md'), '$outputRoot/about.md');
  await processFile(File('$contentRoot/music.md'), '$outputRoot/music.md');

  // Write manifest
  final manifestFile = File('$outputRoot/manifest.json');
  await manifestFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(manifest),
  );
  print('Wrote manifest.json');
}

Future<Map<String, String>?> processFile(File src, String destPath) async {
  if (!src.existsSync()) {
    print('Skipping (not found): ${src.path}');
    return null;
  }

  final raw = await src.readAsString();
  final parsed = parseFrontmatter(raw);
  final frontmatter = parsed['frontmatter'] as Map;
  var body = parsed['body'] as String;

  final title = frontmatter['title']?.toString() ?? '';
  final dateRaw = frontmatter['date']?.toString() ?? '1970-01-01';
  // Trim timezone: "2021-06-29T08:08:57-04:00" → "2021-06-29"
  final date = dateRaw.length >= 10 ? dateRaw.substring(0, 10) : dateRaw;

  body = transformShortcodes(body);

  final dest = File(destPath);
  await dest.parent.create(recursive: true);
  await dest.writeAsString(body);
  print('Processed: ${src.path} → $destPath');

  return {'title': title, 'date': date};
}

Map<String, dynamic> parseFrontmatter(String content) {
  if (!content.startsWith('---')) {
    return {'frontmatter': <String, dynamic>{}, 'body': content};
  }
  final end = content.indexOf('\n---', 3);
  if (end == -1) {
    return {'frontmatter': <String, dynamic>{}, 'body': content};
  }
  final yamlStr = content.substring(3, end).trim();
  final body = content.substring(end + 4).trimLeft();
  final fm = loadYaml(yamlStr) as YamlMap?;
  final map = fm != null ? Map<String, dynamic>.from(fm) : <String, dynamic>{};
  return {'frontmatter': map, 'body': body};
}

String transformShortcodes(String body) {
  // {{< youtube ID >}} → [youtube:ID]
  body = body.replaceAllMapped(
    RegExp(r'\{\{<\s*youtube\s+(\S+)\s*>\}\}'),
    (m) => '\n\n[youtube:${m.group(1)}]\n\n',
  );

  // {{< figure src="PATH" >}} (with optional other attrs) → ![figure](PATH)
  body = body.replaceAllMapped(
    RegExp(r'\{\{<\s*figure\s[^>]*src="([^"]+)"[^>]*>\}\}'),
    (m) => '![figure](${m.group(1)})',
  );

  // <audio controls>...<source src="PATH"...>...</audio> → [audio:PATH]
  body = body.replaceAllMapped(
    RegExp(
      r'<audio[^>]*>.*?<source\s+src="([^"]+)"[^>]*>.*?</audio>',
      dotAll: true,
    ),
    (m) => '\n\n[audio:${m.group(1)}]\n\n',
  );

  // <p>\n    <a href="PATH" download>\n    LABEL\n    </a>\n</p>
  // → [download:PATH|LABEL]
  body = body.replaceAllMapped(
    RegExp(
      r'<p>\s*<a\s+href="([^"]+)"\s+download>\s*([^\n<]+?)\s*</a>\s*</p>',
      dotAll: true,
    ),
    (m) => '[download:${m.group(1)}|${m.group(2)!.trim()}]',
  );

  // Inline HTML: <i>TEXT</i> → *TEXT*, <b>TEXT</b> → **TEXT**, <br> → \n\n
  body = body.replaceAllMapped(
    RegExp(r'<i>(.*?)</i>', dotAll: true),
    (m) => '*${m.group(1)}*',
  );
  body = body.replaceAllMapped(
    RegExp(r'<b>(.*?)</b>', dotAll: true),
    (m) => '**${m.group(1)}**',
  );
  body = body.replaceAll(RegExp(r'<br\s*/?>'), '\n\n');

  return body;
}
