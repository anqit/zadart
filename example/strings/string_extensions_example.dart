import 'package:zadart/zadart.dart';

/// Examples for the `String` extensions.
void main() {
  // `isDigit` reports whether a single-character string is 0-9.
  print('7'.isDigit); // true
  print('a'.isDigit); // false
  print('12'.isDigit); // false  (single characters only)

  // Handy for validating character-by-character input.
  const input = 'a1b2';
  final digits = input.split('').where((c) => c.isDigit).join();
  print(digits); // 12
}
