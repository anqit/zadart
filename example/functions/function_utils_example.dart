import 'package:zadart/zadart.dart';

/// Examples for the function utilities and the `tap` extension.
void main() {
  // `identity` returns its argument unchanged — handy as a default mapper.
  print([1, 2, 3].map(identity).toList()); // [1, 2, 3]

  // `noop` / `noop1` are do-nothing callbacks for optional handlers.
  runWithCallback(onDone: noop);

  // `tap` runs a side effect on a value and returns the value, so it fits
  // inline in a chain without breaking it apart into statements.
  final total = [1, 2, 3, 4]
      .where((n) => n.isEven)
      .toList()
      .tap((evens) => print('evens: $evens')) // evens: [2, 4]
      .fold<int>(0, (sum, n) => sum + n);
  print('sum: $total'); // sum: 6
}

void runWithCallback({required void Function() onDone}) {
  // ... do work ...
  onDone();
}
