import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

// Each instance needs a unique platform view ID.
int _counter = 0;

class BlogImage extends StatefulWidget {
  // Flutter asset path, e.g. 'assets/content/posts/debugging-gen-3/breakpoint.png'
  final String assetPath;

  const BlogImage({super.key, required this.assetPath});

  @override
  State<BlogImage> createState() => _BlogImageState();
}

class _BlogImageState extends State<BlogImage> {
  late final String _viewId;
  Size? _size;

  @override
  void initState() {
    super.initState();
    _viewId = 'blog-img-${_counter++}';

    // Register the native <img> element once. The src uses an absolute path
    // from the web root so it resolves correctly regardless of the current
    // route URL (go_router changes the path segment).
    final src = '/${widget.assetPath}';
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (_) {
      return web.HTMLImageElement()
        ..src = src
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'fill';
    });

    _resolveSize();
  }

  Future<void> _resolveSize() async {
    final bytes = await rootBundle.load(widget.assetPath);
    final codec =
        await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _size = Size(
          frame.image.width.toDouble(),
          frame.image.height.toDouble(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_size == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = width * _size!.height / _size!.width;
          return SizedBox(
            width: width,
            height: height,
            child: HtmlElementView(viewType: _viewId),
          );
        },
      ),
    );
  }
}
