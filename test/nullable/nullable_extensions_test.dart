import 'package:test/test.dart';
import 'package:zadart/zadart.dart';

void main() {
  group('isNull / isNotNull', () {
    test('reflect nullness', () {
      const String? nothing = null;
      String? something = 'x';
      expect(nothing.isNull, isTrue);
      expect(nothing.isNotNull, isFalse);
      expect(something.isNull, isFalse);
      expect(something.isNotNull, isTrue);
    });
  });

  group('map', () {
    test('transforms a non-null value', () {
      String? name = 'ada';
      expect(name.map((n) => n.toUpperCase()), 'ADA');
    });

    test('short-circuits on null without calling the function', () {
      const String? name = null;
      var called = false;
      final result = name.map((n) {
        called = true;
        return n;
      });
      expect(result, isNull);
      expect(called, isFalse);
    });
  });

  group('asyncMap', () {
    test('awaits the mapper for a non-null value', () async {
      int? n = 21;
      expect(await n.asyncMap((v) async => v * 2), 42);
    });

    test('short-circuits on null without calling the mapper', () async {
      const int? n = null;
      var called = false;
      final result = await n.asyncMap((v) async {
        called = true;
        return v * 2;
      });
      expect(result, isNull);
      expect(called, isFalse);
    });
  });

  group('ifNotNull', () {
    test('runs the callback for a non-null value', () {
      int? n = 5;
      int? seen;
      n.ifNotNull((v) => seen = v, orElse: () => fail('orElse should not run'));
      expect(seen, 5);
    });

    test('runs orElse for null', () {
      const int? n = null;
      var elseRan = false;
      n.ifNotNull((_) => fail('callback should not run'),
          orElse: () => elseRan = true);
      expect(elseRan, isTrue);
    });
  });

  group('filter', () {
    test('keeps the value when the predicate passes', () {
      int? n = 4;
      expect(n.filter((v) => v.isEven), 4);
    });

    test('returns null when the predicate fails', () {
      int? n = 3;
      expect(n.filter((v) => v.isEven), isNull);
    });

    test('short-circuits on null without calling the predicate', () {
      const int? n = null;
      var called = false;
      final result = n.filter((_) {
        called = true;
        return true;
      });
      expect(result, isNull);
      expect(called, isFalse);
    });
  });

  group('whenNull / whenNullGet', () {
    test('produce a value only for null', () {
      const String? missing = null;
      String? present = 'here';
      expect(missing.whenNull('fallback'), 'fallback');
      expect(present.whenNull('fallback'), isNull);
      expect(missing.whenNullGet(() => 'lazy'), 'lazy');
    });

    test('whenNullGet does not evaluate for a non-null value', () {
      String? present = 'here';
      expect(present.whenNullGet(() => fail('should not run')), isNull);
    });
  });
}
