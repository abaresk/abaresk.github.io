import 'package:flutter/material.dart';

class BlogImage extends StatelessWidget {
  // Flutter asset path, e.g. 'assets/content/posts/debugging-gen-3/breakpoint.png'
  final String assetPath;

  const BlogImage({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Image.asset(
        assetPath,
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
