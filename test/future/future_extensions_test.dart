import 'package:test/test.dart';
import 'package:zadart/zadart.dart';

void main() {
  group('thenTap', () {
    test('runs the side effect on the resolved value and passes it through',
        () async {
      int? seen;
      final result =
          await Future.value(7).thenTap((v) => seen = v).then((v) => v + 1);
      expect(seen, 7);
      expect(result, 8);
    });

    test('propagates errors without running the tap', () async {
      var tapRan = false;
      final future =
          Future<int>.error(StateError('boom')).thenTap((_) => tapRan = true);
      await expectLater(future, throwsA(isA<StateError>()));
      expect(tapRan, isFalse);
    });
  });
}
