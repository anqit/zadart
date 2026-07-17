import 'package:test/test.dart';
import 'package:zadart/zadart.dart';

void main() {
  group('identity', () {
    test('returns its argument unchanged', () {
      final list = [1, 2, 3];
      expect(identity(list), same(list));
      expect(identity(42), 42);
    });
  });

  group('cast', () {
    test('returns the value reinterpreted at the target type', () {
      const Object o = 'text';
      final String s = cast(o);
      expect(s, 'text');
    });

    test('throws when the value is not of the target type', () {
      const Object o = 'text';
      expect(() => cast<int, Object>(o), throwsA(isA<TypeError>()));
    });
  });

  group('noop / noop1', () {
    test('do nothing and do not throw', () {
      expect(noop, returnsNormally);
      expect(() => noop1('anything'), returnsNormally);
    });
  });

  group('tap', () {
    test('runs the side effect and returns the receiver', () {
      final list = [1, 2, 3];
      var seen = <int>[];
      final result = list.tap((l) => seen = l);
      expect(result, same(list));
      expect(seen, [1, 2, 3]);
    });

    test('fits inline in a chain', () {
      final captured = <int>[];
      final sum = [1, 2, 3, 4]
          .where((n) => n.isEven)
          .toList()
          .tap(captured.addAll)
          .fold<int>(0, (a, b) => a + b);
      expect(captured, [2, 4]);
      expect(sum, 6);
    });
  });
}
