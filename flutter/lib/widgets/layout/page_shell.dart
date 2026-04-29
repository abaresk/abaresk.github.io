import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'site_header.dart';
import 'site_footer.dart';

class PageShell extends StatefulWidget {
  final Widget child;

  const PageShell({super.key, required this.child});

  @override
  State<PageShell> createState() => _PageShellState();
}

class _PageShellState extends State<PageShell> with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  Timer? _scrollTimer;
  Ticker? _scrollTicker;
  double _scrollVelocity = 0;
  Duration _lastTickTime = Duration.zero;

  static const _scrollSpeed = 1000.0; // px/sec
  static const _scrollStep = 60.0;
  static const _holdDelay = Duration(milliseconds: 200);

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollTicker?.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _beginArrowScroll(double velocity) {
    if (_scrollController.hasClients) {
      final pos = _scrollController.position;
      _scrollController.jumpTo(
        (pos.pixels + velocity.sign * _scrollStep * 0.4)
            .clamp(0.0, pos.maxScrollExtent),
      );
    }
    _scrollTimer?.cancel();
    _scrollTimer = Timer(_holdDelay, () {
      _scrollTimer = null;
      _scrollVelocity = velocity;
      _lastTickTime = Duration.zero;
      _scrollTicker?.dispose();
      _scrollTicker = createTicker(_onScrollTick)..start();
    });
  }

  void _onScrollTick(Duration elapsed) {
    if (_lastTickTime == Duration.zero) {
      _lastTickTime = elapsed;
      return;
    }
    final dt = (elapsed - _lastTickTime).inMicroseconds / 1e6;
    _lastTickTime = elapsed;
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    _scrollController.jumpTo(
      (pos.pixels + _scrollVelocity * dt).clamp(0.0, pos.maxScrollExtent),
    );
  }

  void _beginPageScroll(double pageStep) {
    void animatePage(Duration duration) {
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position;
      _scrollController.animateTo(
        (pos.pixels + pageStep).clamp(0.0, pos.maxScrollExtent),
        duration: duration,
        curve: Curves.easeOut,
      );
    }

    animatePage(const Duration(milliseconds: 150));
    _scrollTimer?.cancel();
    _scrollTimer = Timer(_holdDelay, () {
      _scrollTimer = Timer.periodic(
        const Duration(milliseconds: 85),
        (_) => animatePage(const Duration(milliseconds: 85)),
      );
    });
  }

  void _endScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    _scrollTicker?.stop();
    _scrollTicker?.dispose();
    _scrollTicker = null;
    _scrollVelocity = 0;
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    final key = event.logicalKey;
    final isScrollKey = key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.pageDown ||
        key == LogicalKeyboardKey.pageUp;

    if (event is KeyUpEvent && isScrollKey) {
      _endScroll();
      return KeyEventResult.handled;
    }

    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (!_scrollController.hasClients) return KeyEventResult.ignored;

    final pos = _scrollController.position;
    final page = pos.viewportDimension * 0.9;
    final isJumpModifier = defaultTargetPlatform == TargetPlatform.macOS
        ? HardwareKeyboard.instance.isMetaPressed
        : HardwareKeyboard.instance.isControlPressed;

    switch (key) {
      case LogicalKeyboardKey.arrowDown:
        if (isJumpModifier) {
          _scrollController.animateTo(pos.maxScrollExtent,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut);
        } else {
          _beginArrowScroll(_scrollSpeed);
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        if (isJumpModifier) {
          _scrollController.animateTo(0.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut);
        } else {
          _beginArrowScroll(-_scrollSpeed);
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageDown:
        _beginPageScroll(page);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageUp:
        _beginPageScroll(-page);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.home:
        _scrollController.animateTo(0.0,
            duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.end:
        _scrollController.animateTo(pos.maxScrollExtent,
            duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (_, event) => _handleKeyEvent(event),
        child: SelectionArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      const SiteHeader(),
                      widget.child,
                      const SiteFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
