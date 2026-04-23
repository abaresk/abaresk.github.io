import 'package:flutter/material.dart';
import 'router/router.dart';
import 'theme/app_theme.dart';

class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Abaresk's Blog",
      theme: AppTheme.build(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
