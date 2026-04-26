import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubeEmbed extends StatefulWidget {
  final String videoId;
  const YouTubeEmbed({super.key, required this.videoId});

  @override
  State<YouTubeEmbed> createState() => _YouTubeEmbedState();
}

class _YouTubeEmbedState extends State<YouTubeEmbed> {
  bool _playing = false;
  bool _hovered = false;
  YoutubePlayerController? _controller;

  void _onPlay() {
    setState(() {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: widget.videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          strictRelatedVideos: true,
        ),
      );
      _playing = true;
    });
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _playing
          ? YoutubePlayer(controller: _controller!)
          : _buildThumbnail(),
    );
  }

  Widget _buildThumbnail() {
    final thumbnailUrl = YoutubePlayerController.getThumbnail(
      videoId: widget.videoId,
      quality: ThumbnailQuality.max,
      webp: false,
    );

    return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: _onPlay,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(child: ColoredBox(color: Colors.black)),
                Positioned.fill(
                  child: Image.network(
                    thumbnailUrl,
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const Positioned.fill(
                    child: ColoredBox(color: Color(0x33000000))),
                AnimatedScale(
                  scale: _hovered ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: const _PlayButton(),
                ),
              ],
            ),
          ),
        ));
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
    );
  }
}
