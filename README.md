# zadart

A collection of general-purpose utility functions and extensions for everyday
Dart programming.

> *"zada" is Hindi for "more" — a nod to the `more-<lang>` utility packages
> found across other ecosystems.*

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  zadart: ^0.1.0
```

Then import it:

```dart
import 'package:zadart/zadart.dart';
```

## Usage

A few examples of what's inside — see the API docs for the full surface.

### Nullable extensions

```dart
String? name = maybeName();

// Transform only when non-null.
final greeting = name.map((n) => 'Hello, $n');

// Run side effects, with an optional else branch.
name.ifNotNull(print, orElse: () => print('no name'));

// Keep the value only if it passes a predicate.
final nonEmpty = name.filter((n) => n.isNotEmpty);
```

### Collection extensions

```dart
// De-duplicate, optionally by a derived key.
[1, 2, 2, 3].unique();                       // [1, 2, 3]

// Map/filter that drops nulls in one pass.
['1', 'x', '2'].collect(int.tryParse);       // [1, 2]

// Set-like difference and merge operators.
[1, 2, 3] - [2];                             // [1, 3]
{'a': 1} + {'b': 2};                         // {a: 1, b: 2}

// Merge maps with a combining function for shared keys.
{'a': 1}.merge({'a': 2, 'b': 3}, (x, y) => x + y);  // {a: 3, b: 3}
```

### Composable comparators

```dart
final byName = Comparing<Person>().by((p) => p.name);
final byAgeDesc = Comparing<Person>().by((p) => p.age).reversed();

people.sort(byName.then(byAgeDesc));
```

### Trie

```dart
final trie = Trie<String, int>.fromEntries([
  (['a', 'b'], 1),
  (['a', 'c'], 2),
]);

trie.get(['a', 'b']);          // 1
trie.containsKey(['a', 'c']);  // true

// Tries are immutable; insert returns a new trie.
final updated = trie.insert(['a', 'd'], 3);
```

## Additional information

Issues and contributions are welcome at
<https://github.com/anqit/zadart>.
