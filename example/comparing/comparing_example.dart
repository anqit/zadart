import 'package:zadart/zadart.dart';

typedef Person = ({String name, int age, bool active});

/// A type that does *not* implement [Comparable], used below to show how to
/// build comparators for such types.
class Rgb {
  final int r, g, b;
  const Rgb(this.r, this.g, this.b);

  int get luminance => r + g + b;

  @override
  String toString() => 'Rgb($r,$g,$b)';
}

/// Examples for composable comparators via [Comparing] and the `Comparator`
/// extensions.
void main() {
  final people = <Person>[
    (name: 'Ada', age: 36, active: true),
    (name: 'Alan', age: 41, active: false),
    (name: 'Grace', age: 36, active: true),
    (name: 'Alan', age: 30, active: true),
  ];

  // `by` builds a comparator from a selector — but note it requires the
  // selected type to implement `Comparable` (here `String`). The same applies
  // to `byNullable` and `thenBy`.
  final byName = Comparing<Person>().by((p) => p.name);

  // Chain comparators: sort by name, then by age descending as a tie-breaker.
  // `reversed()` flips an existing comparator's direction.
  final byNameThenAgeDesc = byName.then(
    Comparing<Person>().by((p) => p.age).reversed(),
  );

  final sorted = [...people]..sort(byNameThenAgeDesc);
  for (final p in sorted) {
    print('${p.name} (${p.age})');
  }
  // Ada (36)
  // Alan (41)
  // Alan (30)
  // Grace (36)

  // `thenBy` chains an additional selector without building a second
  // `Comparing`. Pass `reversed: true` to sort that step in descending order
  // (equivalent to calling `.reversed()` on just that step).
  final byNameThenAgeDescShorthand = byName.thenBy((p) => p.age, reversed: true);
  print(([...people]..sort(byNameThenAgeDescShorthand))
      .map((p) => '${p.name} ${p.age}')
      .toList());
  // [Ada 36, Alan 41, Alan 30, Grace 36]

  // `byBool` / `thenByBool` order `true` before `false`.
  // Here active people come first, ties broken by name.
  final byActiveThenName = Comparing<Person>()
      .byBool((p) => p.active)
      .thenBy((p) => p.name);
  print(([...people]..sort(byActiveThenName)).map((p) => p.name).toList());
  // [Ada, Alan, Grace, Alan]  (active=true first, then by name)

  // `reversed: true` on `thenByBool` flips that ordering to `false` before
  // `true` — inactive people first.
  final byInactiveThenName = Comparing<Person>()
      .by((p) => p.name)
      .thenByBool((p) => p.active, reversed: true);
  print(([...people]..sort(byInactiveThenName))
      .map((p) => '${p.name} active=${p.active}')
      .toList());

  // `byNullable` puts nulls last regardless of sort direction.
  final scores = <({String id, int? score})>[
    (id: 'a', score: 10),
    (id: 'b', score: null),
    (id: 'c', score: 5),
  ];
  final byScore = Comparing<({String id, int? score})>()
      .byNullable((s) => s.score);
  print(([...scores]..sort(byScore)).map((s) => s.id).toList());
  // [c, a, b]

  // You don't have to start from `Comparing` at all. If you already hold a
  // raw `Comparator<T>` (here a plain function), use it directly — and every
  // chaining method (`then`, `reversed`, `thenBy`, ...) hangs off it too.
  int byAge(Person a, Person b) => a.age.compareTo(b.age);
  print(([...people]..sort(byAge)).map((p) => p.age).toList());
  // [30, 36, 36, 41]
  print(([...people]..sort(byAge.reversed().thenBy((p) => p.name)))
      .map((p) => '${p.name} ${p.age}')
      .toList());
  // [Alan 41, Ada 36, Grace 36, Alan 30]

  // For types that don't implement `Comparable` (like `Rgb`), use
  // `withComparatorBy` and supply your own compare function.
  final swatches = <({String label, Rgb color})>[
    (label: 'dark', color: const Rgb(10, 10, 10)),
    (label: 'light', color: const Rgb(240, 240, 240)),
    (label: 'mid', color: const Rgb(120, 120, 120)),
  ];
  final byLuminance = Comparing<({String label, Rgb color})>().withComparatorBy(
    (s) => s.color,
    (a, b) => a.luminance.compareTo(b.luminance),
  );
  print(([...swatches]..sort(byLuminance)).map((s) => s.label).toList());
  // [dark, mid, light]

  // `thenWithComparatorBy` chains the same idea as a tie-breaker after an
  // existing comparator.
  final byLabelThenLuminance = Comparing<({String label, Rgb color})>()
      .by((s) => s.label)
      .thenWithComparatorBy(
        (s) => s.color,
        (a, b) => a.luminance.compareTo(b.luminance),
      );
  print(([...swatches]..sort(byLabelThenLuminance)).map((s) => s.label).toList());
  // [dark, light, mid]
}
