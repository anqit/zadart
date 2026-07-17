import 'package:zadart/zadart.dart';

/// Examples for the `Future` extensions.
Future<void> main() async {
  // `thenTap` runs a side effect on the resolved value and passes it through,
  // so you can log or record progress mid-chain without breaking it.
  final user = await fetchUser()
      .thenTap((u) => print('loaded: $u'))
      .then((u) => u.toUpperCase());

  print(user); // ADA
}

Future<String> fetchUser() async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
  return 'ada';
}
