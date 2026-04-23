import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/post.dart';

class ContentService {
  static ContentService? _instance;
  static ContentService get instance => _instance ??= ContentService._();
  ContentService._();

  Map<String, dynamic>? _manifest;

  Future<Map<String, dynamic>> _loadManifest() async {
    if (_manifest != null) return _manifest!;
    final raw = await rootBundle.loadString('assets/content/manifest.json');
    _manifest = json.decode(raw) as Map<String, dynamic>;
    return _manifest!;
  }

  Future<List<Post>> loadPosts() async {
    final manifest = await _loadManifest();
    final list = manifest['posts'] as List<dynamic>;
    return list
        .map((e) => Post.fromJson(e as Map<String, dynamic>, 'posts'))
        .toList();
  }

  Future<List<Post>> loadPokemonMods() async {
    final manifest = await _loadManifest();
    final list = manifest['mods']['pokemon'] as List<dynamic>;
    return list
        .map((e) => Post.fromJson(e as Map<String, dynamic>, 'mods/pokemon'))
        .toList();
  }

  Future<Post?> loadPostMeta(String slug) async {
    final posts = await loadPosts();
    for (final p in posts) {
      if (p.slug == slug) return p;
    }
    return null;
  }

  Future<Post?> loadPokemonModMeta(String slug) async {
    final mods = await loadPokemonMods();
    for (final m in mods) {
      if (m.slug == slug) return m;
    }
    return null;
  }

  Future<String> loadPost(String slug) async {
    return rootBundle.loadString('assets/content/posts/$slug.md');
  }

  Future<String> loadPokemonMod(String slug) async {
    return rootBundle.loadString('assets/content/mods/pokemon/$slug.md');
  }

  Future<String> loadPage(String name) async {
    return rootBundle.loadString('assets/content/$name.md');
  }
}
