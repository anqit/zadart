import 'package:test/test.dart';
import 'package:zadart/zadart.dart';

typedef Person = ({String name, int age});

/// A type that does not implement [Comparable].
class Box {
  final int n;
  const Box(this.n);
}

void main() {
  group('BooleanComparable', () {
    test('orders true before false', () {
      expect(BooleanComparable.compare(true, false), lessThan(0));
      expect(BooleanComparable.compare(false, true), greaterThan(0));
      expect(BooleanComparable.compare(true, true), 0);
      expect(BooleanComparable.compare(false, false), 0);
    });

    test('compareTo delegates to compare', () {
      expect(const BooleanComparable(true).compareTo(false), lessThan(0));
    });
  });

  group('Comparing.fromComparable', () {
    test('builds a comparator from Comparable.compareTo', () {
      final c = Comparing.fromComparable<num>();
      expect(c(1, 2), lessThan(0));
      expect(c(2, 2), 0);
      expect(c(3, 2), greaterThan(0));
    });
  });

  group('Comparing.by', () {
    test('sorts by a Comparable selector', () {
      final byLength = Comparing<String>().by((s) => s.length);
      final list = ['ccc', 'a', 'bb']..sort(byLength);
      expect(list, ['a', 'bb', 'ccc']);
    });
  });

  group('Comparing.byNullable', () {
    test('orders nulls last', () {
      final byScore = Comparing<int?>().byNullable((x) => x);
      final list = [3, null, 1]..sort(byScore);
      expect(list, [1, 3, null]);
    });
  });

  group('Comparing.byBool', () {
    test('orders true before false', () {
      final byActive = Comparing<(String, bool)>().byBool((t) => t.$2);
      final list = [('a', false), ('b', true)]..sort(byActive);
      expect(list.map((t) => t.$1), ['b', 'a']);
    });
  });

  group('Comparing.withComparatorBy', () {
    test('builds a comparator for a non-Comparable type', () {
      final byN = Comparing<Box>().withComparatorBy(
        (b) => b,
        (a, b) => a.n.compareTo(b.n),
      );
      final list = [const Box(3), const Box(1), const Box(2)]..sort(byN);
      expect(list.map((b) => b.n), [1, 2, 3]);
    });
  });

  group('Comparator.reversed', () {
    test('flips ordering', () {
      final desc = Comparing<int>().by(identity).reversed();
      final list = [1, 3, 2]..sort(desc);
      expect(list, [3, 2, 1]);
    });
  });

  group('Comparator.then / thenBy', () {
    test('uses the next comparator as a tie-breaker', () {
      final people = <Person>[
        (name: 'Alan', age: 41),
        (name: 'Ada', age: 36),
        (name: 'Alan', age: 30),
      ];
      final cmp = Comparing<Person>().by((p) => p.name).thenBy((p) => p.age);
      final sorted = [...people]..sort(cmp);
      expect(sorted.map((p) => '${p.name}${p.age}'),
          ['Ada36', 'Alan30', 'Alan41']);
    });

    test('thenBy reversed sorts that step descending', () {
      final people = <Person>[
        (name: 'Alan', age: 30),
        (name: 'Alan', age: 41),
        (name: 'Ada', age: 36),
      ];
      final cmp = Comparing<Person>()
          .by((p) => p.name)
          .thenBy((p) => p.age, reversed: true);
      final sorted = [...people]..sort(cmp);
      expect(sorted.map((p) => '${p.name}${p.age}'),
          ['Ada36', 'Alan41', 'Alan30']);
    });
  });

  group('Comparator.thenByBool', () {
    test('true before false, flippable with reversed', () {
      final data = <(String, bool)>[('a', false), ('a', true)];
      final cmp = Comparing<(String, bool)>()
          .by((t) => t.$1)
          .thenByBool((t) => t.$2);
      expect(([...data]..sort(cmp)).map((t) => t.$2), [true, false]);

      final cmpRev = Comparing<(String, bool)>()
          .by((t) => t.$1)
          .thenByBool((t) => t.$2, reversed: true);
      expect(([...data]..sort(cmpRev)).map((t) => t.$2), [false, true]);
    });
  });

  group('Comparator.thenWithComparatorBy', () {
    test('chains a custom comparator as a tie-breaker', () {
      final data = <(String, Box)>[
        ('a', const Box(2)),
        ('a', const Box(1)),
      ];
      final cmp = Comparing<(String, Box)>().by((t) => t.$1).thenWithComparatorBy(
            (t) => t.$2,
            (x, y) => x.n.compareTo(y.n),
          );
      expect(([...data]..sort(cmp)).map((t) => t.$2.n), [1, 2]);
    });
  });

  group('Comparator.contraMap', () {
    test('adapts a comparator to a different input type', () {
      final Comparator<num> byInt = Comparing.fromComparable<num>();
      final Comparator<String> byLength = byInt.contraMap((s) => s.length);
      final list = ['ccc', 'a', 'bb']..sort(byLength);
      expect(list, ['a', 'bb', 'ccc']);
    });
  });
}
