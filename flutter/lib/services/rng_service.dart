// Dart ports of pcg-random.js and mersenne-twister.js.
// All 32-bit values are masked with 0xFFFFFFFF to emulate unsigned 32-bit
// overflow on Dart web (where ints are 53-bit JS numbers).

const int _u32 = 0xFFFFFFFF;

int _lo(int v) => v & _u32;

class Pcg32 {
  static const int _mulHi = 0x5851f42d;
  static const int _mulLo = 0x4c957f2d;
  static const int _defaultIncLo = 0xf767814f;
  static const int _defaultIncHi = 0x14057b7e;

  int _stateLo = 0;
  int _stateHi = 0;
  int _incLo = 0;
  int _incHi = 0;

  Pcg32(int seedLo32) {
    _incLo = _lo(_defaultIncLo | 1);
    _incHi = _lo(_defaultIncHi);
    _stateLo = 0;
    _stateHi = 0;
    _next32Internal();
    final tmp = _add64(_stateLo, _stateHi, _lo(seedLo32), 0);
    _stateLo = tmp[0];
    _stateHi = tmp[1];
    _next32Internal();
  }

  int next32() => _next32Internal();

  int _next32Internal() {
    final oldLo = _lo(_stateLo);
    final oldHi = _lo(_stateHi);

    // state = state * MUL + INC (64-bit)
    final mulResult = _mul64(oldLo, oldHi, _mulLo, _mulHi);
    final addResult = _add64(mulResult[0], mulResult[1], _incLo, _incHi);
    _stateLo = addResult[0];
    _stateHi = addResult[1];

    // xorshift: ((old >> 18) ^ old) >> 27
    final xsHi = oldHi >> 18;
    final xsLo = _lo(((oldLo >> 18) | (oldHi << 14)));
    final xsHi2 = _lo(xsHi ^ oldHi);
    final xsLo2 = _lo(xsLo ^ oldLo);
    final xorshifted = _lo((xsLo2 >> 27) | (xsHi2 << 5));

    // rotate right by (oldHi >> 27)
    final rot = oldHi >> 27;
    final rot2 = _lo((-rot) & 31);
    return _lo((xorshifted >> rot) | (xorshifted << rot2));
  }

  static List<int> _add64(int aLo, int aHi, int bLo, int bHi) {
    final al = _lo(aLo);
    final ah = _lo(aHi);
    final bl = _lo(bLo);
    final bh = _lo(bHi);
    final lo = _lo(al + bl);
    final carry = lo < al ? 1 : 0;
    final hi = _lo(ah + bh + carry);
    return [lo, hi];
  }

  static List<int> _mul64(int aLo, int aHi, int bLo, int bHi) {
    final al = _lo(aLo);
    final ah = _lo(aHi);
    final bl = _lo(bLo);
    final bh = _lo(bHi);

    final aLH = (al >> 16) & 0xffff;
    final aLL = al & 0xffff;
    final bLH = (bl >> 16) & 0xffff;
    final bLL = bl & 0xffff;

    final aLHxbLL = _lo(aLH * bLL);
    final aLLxbLH = _lo(aLL * bLH);
    final aLHxbLH = _lo(aLH * bLH);
    final aLLxbLL = _lo(aLL * bLL);

    final aLHxbLL0 = aLHxbLL >> 16;
    final aLHxbLL1 = _lo(aLHxbLL << 16);
    final aLLxbLH0 = aLLxbLH >> 16;
    final aLLxbLH1 = _lo(aLLxbLH << 16);

    final l0 = _lo(aLHxbLL1 + aLLxbLH1);
    final c0 = l0 < aLHxbLL1 ? 1 : 0;
    final h0 = _lo(aLHxbLL0 + aLLxbLH0 + c0);

    // imul(aL, bH) and imul(aH, bL) — only need lower 32 bits
    final aLxbH = _lo(al * bh);
    final aHxbL = _lo(ah * bl);

    final resLo = _lo(l0 + aLLxbLL);
    final c1 = resLo < aLLxbLL ? 1 : 0;
    final h1 = _lo(aLHxbLH + h0 + c1);
    final resHi = _lo(aLxbH + aHxbL + h1);

    return [resLo, resHi];
  }
}

class MersenneTwister {
  static const int _n = 624;
  static const int _m = 397;
  static const int _matrixA = 0x9908b0df;
  static const int _upperMask = 0x80000000;
  static const int _lowerMask = 0x7fffffff;

  final List<int> _mt = List.filled(_n, 0);
  int _mti = _n + 1;

  MersenneTwister(int seed) {
    _initSeed(seed);
  }

  void _initSeed(int s) {
    _mt[0] = _lo(s);
    for (_mti = 1; _mti < _n; _mti++) {
      final prev = _mt[_mti - 1];
      final s2 = prev ^ (prev >> 30);
      _mt[_mti] = _lo(
        _lo((((s2 & 0xffff0000) >> 16) * 1812433253) << 16) +
            (s2 & 0x0000ffff) * 1812433253 +
            _mti,
      );
    }
  }

  int randomInt() {
    int y;
    const mag01 = [0x0, _matrixA];

    if (_mti >= _n) {
      if (_mti == _n + 1) _initSeed(5489);
      int kk;
      for (kk = 0; kk < _n - _m; kk++) {
        y = (_mt[kk] & _upperMask) | (_mt[kk + 1] & _lowerMask);
        _mt[kk] = _mt[kk + _m] ^ (y >> 1) ^ mag01[y & 0x1];
      }
      for (; kk < _n - 1; kk++) {
        y = (_mt[kk] & _upperMask) | (_mt[kk + 1] & _lowerMask);
        _mt[kk] = _mt[kk + (_m - _n)] ^ (y >> 1) ^ mag01[y & 0x1];
      }
      y = (_mt[_n - 1] & _upperMask) | (_mt[0] & _lowerMask);
      _mt[_n - 1] = _mt[_m - 1] ^ (y >> 1) ^ mag01[y & 0x1];
      _mti = 0;
    }

    y = _mt[_mti++];
    y ^= (y >> 11);
    y ^= (y << 7) & 0x9d2c5680;
    y ^= (y << 15) & 0xefc60000;
    y ^= (y >> 18);
    return _lo(y);
  }
}

int seedFromDate(DateTime date) =>
    date.year + date.month * 0x100 + date.day * 0x10000;

int daysSinceEpoch(DateTime date) {
  final epoch = DateTime.utc(1970, 1, 1);
  final d = DateTime.utc(date.year, date.month, date.day);
  return d.difference(epoch).inDays;
}
