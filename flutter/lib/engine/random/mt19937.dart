import 'package:mt19937/mt19937.dart';

import '../random/rng.dart';
import '../math/uint.dart';

class RandomMt19937 extends Rng {
  late MersenneTwisterEngine _random;

  RandomMt19937([Uint64? seed]) {
    if (seed == null || seed == Uint64.zero) {
      seed = Uint64(DateTime.now().microsecondsSinceEpoch);
    }

    _random = MersenneTwisterEngine.w32()..init(seed.toInt64());
  }

  @override
  Uint32 nextUint32() => Uint32(_random.nextInt64().toInt());
}
