import 'package:xrandom/xrandom.dart';

import '../random/rng.dart';
import '../math/uint.dart';

class RandomXoshiro extends Rng {
  late Xoshiro256pp _random;

  RandomXoshiro([Uint64? seed]) {
    if (seed == null || seed == Uint64.zero) {
      seed = Uint64(DateTime.now().microsecondsSinceEpoch);
    }

    final splitmix = Splitmix64(seed.toInt());
    final seed1 = splitmix.nextRaw64();
    final seed2 = splitmix.nextRaw64();
    final seed3 = splitmix.nextRaw64();
    final seed4 = splitmix.nextRaw64();

    _random = Xoshiro256pp(seed1, seed2, seed3, seed4);
  }

  @override
  Uint32 nextUint32() => Uint32(_random.nextRaw32());
}
