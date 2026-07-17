import 'package:zadart/zadart.dart';

/// Examples for the nullable extensions, which let you work with `T?` values
/// without repetitive null checks.
Future<void> main() async {
  String? name = 'Ada';
  String? missing;

  // `map` transforms only when non-null, otherwise stays null.
  print(name.map((n) => 'Hello, $n')); // Hello, Ada
  print(missing.map((n) => 'Hello, $n')); // null

  // `ifNotNull` runs a side effect, with an optional `orElse` branch.
  missing.ifNotNull(print, orElse: () => print('(no name)')); // (no name)

  // `filter` keeps the value only when the predicate holds.
  print('  ada  '.trim().filter((s) => s.isNotEmpty)); // ada
  print(''.filter((s) => s.isNotEmpty)); // null

  // Note: `filter` (like `map` and `ifNotNull`) short-circuits on a null
  // receiver — the predicate is never called and you simply get null back.
  print(missing.filter((s) => throw StateError('never runs'))); // null

  // `whenNull` produces a value only when the receiver is null (and null
  // otherwise — it is the null-side counterpart to `map`, not `??`).
  print(missing.whenNull('default')); // default
  print(name.whenNull('default')); // null  (name was non-null)

  // `isNull` / `isNotNull` read more clearly than `== null`.
  print(name.isNotNull); // true

  // Async variants mirror the sync ones for `Future`-returning callbacks.
  final greeting = await name.asyncMap((n) async => 'Hi, $n');
  print(greeting); // Hi, Ada
}
