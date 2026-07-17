import 'package:zadart/zadart.dart';

/// Examples for the collection extensions on `List`, `Map`, `Iterable` and
/// `MapEntry`.
void main() {
  listExamples();
  iterableExamples();
  mapExamples();
}

void listExamples() {
  print('--- List ---');

  // `unique` removes duplicates, preserving first-encounter order.
  print([3, 1, 3, 2, 1].unique()); // [3, 1, 2]

  // Provide `by` to de-duplicate on a derived key.
  final people = [
    (id: 1, name: 'Ada'),
    (id: 2, name: 'Alan'),
    (id: 1, name: 'Ada (dup)'),
  ];
  print(people.unique(by: (p) => p.id).map((p) => p.name).toList());
  // [Ada, Alan]

  // `collect` maps and drops nulls in a single pass.
  print(['1', 'nope', '2'].collect(int.tryParse)); // [1, 2]

  // `without` / `-` returns a new list with the given elements removed.
  print([1, 2, 3, 4] - [2, 4]); // [1, 3]
}

void iterableExamples() {
  print('--- Iterable ---');

  final words = ['apple', 'avocado', 'banana', 'blueberry'];

  // `toMap` keys each element by a derived value.
  print(words.toMap((w) => w[0]));
  // {a: avocado, b: blueberry}  (later entries win)

  // `doesNotContain` reads better than `!x.contains(...)`.
  print(words.doesNotContain('cherry')); // true

  // `deepEquals` compares nested structures by value.
  print([
    [1, 2],
    [3],
  ].deepEquals([
    [1, 2],
    [3],
  ])); // true
}

void mapExamples() {
  print('--- Map ---');

  final inventory = {'apples': 3, 'pears': 1};

  // `mapValues` transforms values while keeping keys.
  print(inventory.mapValues((qty) => qty * 2)); // {apples: 6, pears: 2}

  // `+` unions two maps; `-` removes keys present in another map.
  print(inventory + {'plums': 5}); // {apples: 3, pears: 1, plums: 5}
  print(inventory - {'pears': 0}); // {apples: 3}

  // `merge` combines two maps, resolving shared keys with the merger.
  final monday = {'apples': 3, 'pears': 1};
  final tuesday = {'apples': 2, 'plums': 4};
  print(monday.merge(tuesday, (a, b) => a + b));
  // {apples: 5, pears: 1, plums: 4}

  // `where` / `whereNot` filter entries by key and value.
  print(inventory.where((item, qty) => qty > 1)); // {apples: 3}

  // `updated` / `without` return new maps (originals untouched).
  print(inventory.updated('pears', 10)); // {apples: 3, pears: 10}
  print(inventory.without('pears')); // {apples: 3}
}
