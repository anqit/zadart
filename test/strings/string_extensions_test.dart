import 'package:test/test.dart';
import 'package:zadart/zadart.dart';

void main() {
  group('isDigit', () {
    test('is true for each single digit 0-9', () {
      for (var i = 0; i <= 9; i++) {
        expect('$i'.isDigit, isTrue, reason: '$i should be a digit');
      }
    });

    test('is false for non-digit characters', () {
      for (final c in ['a', 'Z', ' ', '-', '.', '٩']) {
        expect(c.isDigit, isFalse, reason: '"$c" should not be a digit');
      }
    });

    test('is false for empty and multi-character strings', () {
      expect(''.isDigit, isFalse);
      expect('12'.isDigit, isFalse);
      expect('1a'.isDigit, isFalse);
    });
  });
}
