import 'dart:typed_data';
import 'package:fixnum/fixnum.dart';
import '../math/uint.dart';

const _maxUint32 = (1 << 32) - 1;

abstract class Rng {
  /// Generates a non-negative random integer uniformly distributed in the range
  /// from 0 to (2^32)-1, both inclusive.
  Uint32 nextUint32();

  /// Generates a non-negative random integer uniformly distributed in the range
  /// from 0 to (2^64)-1, both inclusive.
  Uint64 nextUint64() =>
      (nextUint32().toUint64() << 32) | nextUint32().toUint64();

  int randInt([int? max]) => randInt32(max);

  int randInt32([int? max]) {
    max ??= Int32.MAX_VALUE.toInt();
    assert(max > 0);

    final limit = _maxUint32 - (_maxUint32 % max);
    while (true) {
      final result = nextUint32();
      if (result < limit.toInt()) {
        return (result % max).toInt();
      }
    }
  }

  /// Generates a random number uniformly from the range [min] (inclusive) to [max]
  /// (exclusive).
  int randIntRange(int min, int max) => randInt32Range(min, max);

  /// Generates a random number uniformly from the range [min] (inclusive) to [max]
  /// (exclusive).
  int randInt32Range(int min, int max) {
    assert(max > min);
    return min + randInt32(max - min);
  }

  /// Generates a random double in the range [0, 1.0).
  double randDouble() {
    final mantissa = (nextUint64() >> 12);
    return (ByteData(8)
              ..setUint32(0, ((mantissa >> 32) | 0x3FF00000).toInt())
              ..setUint32(4, (mantissa & 0xFFFFFFFF).toInt()))
            .getFloat64(0) -
        1;
  }

  /// Generates a random double in the range `[min, max]`.
  double randDoubleRange(double min, double max) {
    assert(max > min);
    return min + (randDouble() * (max - min));
  }

  bool randBool() => (nextUint32() >> 31) == Uint32(1);
}
