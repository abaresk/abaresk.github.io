import '../random/rng.dart';
import '../math/uint.dart';

class RandomPcg extends Rng {
  static final _multiplier = Uint64.parseHex('5851f42d4c957f2d');
  static final _increment = Uint64.parseHex('14057b7ef767814f');

  late Uint64 _state;

  RandomPcg([Uint64? seed]) {
    if (seed == null || seed == Uint64.zero) {
      seed = Uint64(DateTime.now().microsecondsSinceEpoch);
    }
    _state = seed + _increment;
    nextUint32();
  }

  Uint32 _rotr32(Uint32 x, int r) => (x >> r) | (x << (32 - r));

  @override
  Uint32 nextUint32() {
    final x = _state;
    final count = x >> 59;

    _state = x * _multiplier + _increment;

    final xorshifted = ((x >> 18) ^ x) >> 27;
    return _rotr32(xorshifted.toUint32(), count.toInt());
  }
}
