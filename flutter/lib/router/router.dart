import 'package:go_router/go_router.dart';
import '../widgets/home/home_page.dart';
import '../widgets/posts/posts_page.dart';
import '../widgets/posts/post_page.dart';
import '../widgets/mods/mods_page.dart';
import '../widgets/mods/pokemon_index_page.dart';
import '../widgets/mods/mod_detail_page.dart';
import '../widgets/music/music_page.dart';
import '../widgets/about/about_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, state) => const HomePage()),
    GoRoute(path: '/posts', builder: (ctx, state) => const PostsPage()),
    GoRoute(
      path: '/posts/:slug',
      builder: (ctx, state) =>
          PostPage(slug: state.pathParameters['slug']!),
    ),
    GoRoute(path: '/mods', builder: (ctx, state) => const ModsPage()),
    GoRoute(
      path: '/mods/pokemon',
      builder: (ctx, state) => const PokemonIndexPage(),
    ),
    GoRoute(
      path: '/mods/pokemon/:slug',
      builder: (ctx, state) =>
          ModDetailPage(slug: state.pathParameters['slug']!),
    ),
    GoRoute(path: '/music', builder: (ctx, state) => const MusicPage()),
    GoRoute(path: '/about', builder: (ctx, state) => const AboutPage()),
  ],
);
