import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/home/home_page.dart';
import '../widgets/posts/posts_page.dart';
import '../widgets/posts/post_page.dart';
import '../widgets/mods/mods_page.dart';
import '../widgets/mods/pokemon_index_page.dart';
import '../widgets/mods/mod_detail_page.dart';
import '../widgets/music/music_page.dart';
import '../widgets/about/about_page.dart';

Page<void> _noTransition(Widget child) =>
    NoTransitionPage<void>(child: child);

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (ctx, state) => _noTransition(const HomePage()),
    ),
    GoRoute(
      path: '/posts',
      pageBuilder: (ctx, state) => _noTransition(const PostsPage()),
    ),
    GoRoute(
      path: '/posts/:slug',
      pageBuilder: (ctx, state) =>
          _noTransition(PostPage(slug: state.pathParameters['slug']!)),
    ),
    GoRoute(
      path: '/mods',
      pageBuilder: (ctx, state) => _noTransition(const ModsPage()),
    ),
    GoRoute(
      path: '/mods/pokemon',
      pageBuilder: (ctx, state) => _noTransition(const PokemonIndexPage()),
    ),
    GoRoute(
      path: '/mods/pokemon/:slug',
      pageBuilder: (ctx, state) =>
          _noTransition(ModDetailPage(slug: state.pathParameters['slug']!)),
    ),
    GoRoute(
      path: '/music',
      pageBuilder: (ctx, state) => _noTransition(const MusicPage()),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (ctx, state) => _noTransition(const AboutPage()),
    ),
  ],
);
