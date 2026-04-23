import 'package:fixnum/fixnum.dart';

class Uint64 {
  /// An [Uint64] constant equal to 0.
  static Uint64 zero = Uint64(0);

  /// An [Uint64] constant equal to 1.
  static Uint64 one = Uint64(1);

  /// An [Uint64] constant equal to 2.
  static Uint64 two = Uint64(2);

  final Int64 _value;

  const Uint64.fromInt64(this._value);

  factory Uint64([int value = 0]) => Uint64.fromInt64(Int64(value));

  static Uint64 parseHex(String source) =>
      Uint64.fromInt64(Int64.parseHex(source));

  static Object _promote(Object value) {
    if (value is Uint64) {
      return value._value;
    } else if (value is Uint32) {
      return value._value.toInt64();
    }
    return value;
  }

  Uint64 operator +(Object other) {
    if (other is Uint64) {
      other = other._value;
    }
    return Uint64.fromInt64(_value + other);
  }

  Uint64 operator *(Object other) {
    other = _promote(other);
    return Uint64.fromInt64(_value * other);
  }

  Uint64 operator &(Object other) {
    other = _promote(other);
    return Uint64.fromInt64(_value & other);
  }

  Uint64 operator |(Object other) {
    other = _promote(other);
    return Uint64.fromInt64(_value | other);
  }

  Uint64 operator ^(Object other) {
    other = _promote(other);
    return Uint64.fromInt64(_value ^ other);
  }

  Uint64 operator >>(int n) => Uint64.fromInt64(_value.shiftRightUnsigned(n));

  Uint64 operator <<(int n) => Uint64.fromInt64(_value << n);

  bool operator <(Object other) => _compareTo(other) < 0;

  bool operator <=(Object other) => _compareTo(other) <= 0;

  bool operator >(Object other) => _compareTo(other) > 0;

  bool operator >=(Object other) => _compareTo(other) >= 0;

  int compareTo(Object other) => _compareTo(other);

  int _compareTo(Object other) {
    if (other is Uint64) {
      other = other._value;
    }
    if (other is int) {
      other = Uint64(other);

      final thisHi = (this >> 32).toUint32();
      final otherHi = (other >> 32).toUint32();
      final compareHi = thisHi.compareTo(otherHi);
      if (compareHi != 0) {
        return compareHi;
      }

      final thisLo = toUint32();
      final otherLo = other.toUint32();
      return thisLo.compareTo(otherLo);
    }

    return _value.compareTo(other);
  }

  int toInt() => _value.toInt();

  Uint32 toUint32() => Uint32.fromInt32(toInt32());

  Int64 toInt64() => _value;

  Int32 toInt32() => _value.toInt32();

  @override
  bool operator ==(Object other) => _value == other;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => _value.toStringUnsigned();
}

class Uint32 {
  /// An [Uint32] constant equal to 0.
  static Uint32 zero = Uint32(0);

  /// An [Uint32] constant equal to 1.
  static Uint32 one = Uint32(1);

  /// An [Uint32] constant equal to 2.
  static Uint32 two = Uint32(2);

  final Int32 _value;

  const Uint32.fromInt32(this._value);

  factory Uint32([int value = 0]) => Uint32.fromInt32(Int32(value));

  static Uint32 fromInt64(Int64 value) => Uint32.fromInt32(value.toInt32());

  static Uint32 parseHex(String source) =>
      Uint32.fromInt32(Int32.parseHex(source));

  static Object _promote(Object value) {
    if (value is Uint32) {
      return value._value;
    }
    return value;
  }

  Uint32 operator +(Uint32 other) =>
      Uint32.fromInt32((_value.toInt64() + other._value.toInt64()).toInt32());

  Uint32 operator *(Uint32 other) =>
      Uint32.fromInt32((_value.toInt64() * other._value.toInt64()).toInt32());

  Uint32 operator %(Object other) {
    other = _promote(other);
    if (other is int) {
      if (other < 0) {
        other = Int64(other) + (Int64(1) << 32);
      }
      return fromInt64(_value.toInt64() % other);
    }
    throw ArgumentError.value(other, 'other', 'not an int, Int32 or Int64');
  }

  Uint32 operator &(Object other) {
    other = _promote(other);
    return Uint32.fromInt32(_value & other);
  }

  Uint32 operator |(Object other) {
    other = _promote(other);
    return Uint32.fromInt32(_value | other);
  }

  Uint32 operator ^(Object other) {
    other = _promote(other);
    return Uint32.fromInt32(_value ^ other);
  }

  Uint32 operator >>(int n) => Uint32.fromInt32(_value.shiftRightUnsigned(n));

  Uint32 operator <<(int n) => Uint32.fromInt32(_value << n);

  bool operator <(Object other) => _compareTo(other) < 0;

  bool operator <=(Object other) => _compareTo(other) <= 0;

  bool operator >(Object other) => _compareTo(other) > 0;

  bool operator >=(Object other) => _compareTo(other) >= 0;

  int compareTo(Object other) => _compareTo(other);

  int _compareTo(Object other) {
    if (other is Uint32) {
      other = other._value;
    }
    if (other is int) {
      final thisBytes = _value.toBytes().reversed.toList();
      final otherBytes = Int32(other).toBytes().reversed.toList();
      for (int i = 0; i < 4; i++) {
        if (thisBytes[i] < otherBytes[i]) {
          return -1;
        } else if (thisBytes[i] > otherBytes[i]) {
          return 1;
        }
      }
      return 0;
    }
    return _value.compareTo(other);
  }

  int toInt() => _value.toInt();

  Uint64 toUint64() => Uint64.fromInt64(toInt64());

  Int64 toInt64() {
    if (_value.isNegative) {
      return _value.toInt64() + (Int64(1) << 32);
    }
    return _value.toInt64();
  }

  @override
  bool operator ==(Object other) => _value == other;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => toInt64().toString();
}
