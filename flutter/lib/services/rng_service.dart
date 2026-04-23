import 'package:abaresk_blog/engine/math/uint.dart';

Uint64 seedFromDate(DateTime date) =>
    Uint64(date.year + date.month * 0x100 + date.day * 0x10000);

int daysSinceEpoch(DateTime date) {
  final epoch = DateTime.utc(1970, 1, 1);
  final d = DateTime.utc(date.year, date.month, date.day);
  return d.difference(epoch).inDays;
}
