import 'package:flutter/material.dart';
import '../../services/rng_service.dart';

class AvatarWidget extends StatefulWidget {
  const AvatarWidget({super.key});

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  late final String _assetPath;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final mt = MersenneTwister(seedFromDate(now));
    final showEarbuds = mt.randomInt() % 32 == 0;
    _assetPath = showEarbuds
        ? 'assets/images/earbuds.png'
        : 'assets/images/avatar.png';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Image.asset(
        _assetPath,
        width: 180,
        fit: BoxFit.contain,
      ),
    );
  }
}
