import 'package:test/test.dart';
import 'package:zadart/zadart.dart';

void main() {
  group('match2', () {
    test('dispatches to ifFirst for a value of the first type', () {
      final result = match2<String, int, bool>(
        7,
        ifFirst: (i) => 'first:$i',
        ifSecond: (b) => 'second:$b',
      );
      expect(result, 'first:7');
    });

    test('dispatches to ifSecond for a value of the second type', () {
      final result = match2<String, int, bool>(
        true,
        ifFirst: (i) => 'first:$i',
        ifSecond: (b) => 'second:$b',
      );
      expect(result, 'second:true');
    });

    test('falls back to otherwise when the first type has no callback', () {
      final result = match2<String, int, bool>(
        7,
        ifSecond: (b) => 'second:$b',
        otherwise: (v) => 'other:$v',
      );
      expect(result, 'other:7');
    });

    test('falls back to otherwise when the second type has no callback', () {
      final result = match2<String, int, bool>(
        true,
        ifFirst: (i) => 'first:$i',
        otherwise: (v) => 'other:$v',
      );
      expect(result, 'other:true');
    });

    test('prefers the specific callback over otherwise', () {
      final result = match2<String, int, bool>(
        7,
        ifFirst: (i) => 'first:$i',
        otherwise: (_) => fail('otherwise should not run'),
      );
      expect(result, 'first:7');
    });

    test('checks types in declared order when a value matches both', () {
      // 5 is both int (I1) and num (I2); the first arm wins.
      final result = match2<String, int, num>(
        5,
        ifFirst: (_) => 'first',
        ifSecond: (_) => 'second',
      );
      expect(result, 'first');
    });

    test('routes null to ifNull', () {
      final result = match2<String, int, bool>(
        null,
        ifFirst: (i) => 'first:$i',
        ifNull: () => 'null',
      );
      expect(result, 'null');
    });

    test('throws ArgumentError for null with no ifNull', () {
      expect(
        () => match2<String, int, bool>(null, ifFirst: (i) => '$i'),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for a value of an unhandled type', () {
      expect(
        () => match2<String, int, bool>(
          'nope',
          ifFirst: (i) => '$i',
          ifSecond: (b) => '$b',
        ),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError when the matched type has neither callback nor otherwise', () {
      // 7 is I1 (int), but only ifSecond is provided and there is no otherwise.
      expect(
        () => match2<String, int, bool>(7, ifSecond: (b) => '$b'),
        throwsArgumentError,
      );
    });
  });

  group('match3', () {
    test('dispatches to each type-specific callback', () {
      String run(dynamic v) => match3<String, int, bool, String>(
            v,
            ifFirst: (i) => 'first:$i',
            ifSecond: (b) => 'second:$b',
            ifThird: (s) => 'third:$s',
          );
      expect(run(1), 'first:1');
      expect(run(true), 'second:true');
      expect(run('x'), 'third:x');
    });

    test('falls back to otherwise for the third type', () {
      final result = match3<String, int, bool, String>(
        'x',
        ifFirst: (i) => 'first:$i',
        otherwise: (v) => 'other:$v',
      );
      expect(result, 'other:x');
    });

    test('routes null to ifNull', () {
      expect(
        match3<String, int, bool, String>(null, ifNull: () => 'null'),
        'null',
      );
    });

    test('throws ArgumentError for an unhandled type', () {
      expect(
        () => match3<String, int, bool, String>(3.14, ifFirst: (i) => '$i'),
        throwsArgumentError,
      );
    });
  });

  group('match4', () {
    test('dispatches to each type-specific callback', () {
      String run(dynamic v) => match4<String, int, bool, String, double>(
            v,
            ifFirst: (i) => 'first:$i',
            ifSecond: (b) => 'second:$b',
            ifThird: (s) => 'third:$s',
            ifFourth: (d) => 'fourth:$d',
          );
      expect(run(1), 'first:1');
      expect(run(true), 'second:true');
      expect(run('x'), 'third:x');
      expect(run(2.5), 'fourth:2.5');
    });

    test('falls back to otherwise for the fourth type', () {
      final result = match4<String, int, bool, String, double>(
        2.5,
        ifFirst: (i) => 'first:$i',
        otherwise: (v) => 'other:$v',
      );
      expect(result, 'other:2.5');
    });

    test('routes null to ifNull', () {
      expect(
        match4<String, int, bool, String, double>(null, ifNull: () => 'null'),
        'null',
      );
    });

    test('throws ArgumentError for an unhandled type', () {
      expect(
        () => match4<String, int, bool, String, double>(
          <int>[1],
          ifFirst: (i) => '$i',
        ),
        throwsArgumentError,
      );
    });
  });

  group('match5', () {
    test('dispatches to each type-specific callback', () {
      String run(dynamic v) =>
          match5<String, int, bool, String, double, List<int>>(
            v,
            ifFirst: (i) => 'first:$i',
            ifSecond: (b) => 'second:$b',
            ifThird: (s) => 'third:$s',
            ifFourth: (d) => 'fourth:$d',
            ifFifth: (l) => 'fifth:$l',
          );
      expect(run(1), 'first:1');
      expect(run(true), 'second:true');
      expect(run('x'), 'third:x');
      expect(run(2.5), 'fourth:2.5');
      expect(run(<int>[9]), 'fifth:[9]');
    });

    test('falls back to otherwise for the fifth type', () {
      final result = match5<String, int, bool, String, double, List<int>>(
        <int>[9],
        ifFirst: (i) => 'first:$i',
        otherwise: (v) => 'other:$v',
      );
      expect(result, 'other:[9]');
    });

    test('routes null to ifNull', () {
      expect(
        match5<String, int, bool, String, double, List<int>>(
          null,
          ifNull: () => 'null',
        ),
        'null',
      );
    });

    test('throws ArgumentError for an unhandled type', () {
      expect(
        () => match5<String, int, bool, String, double, List<int>>(
          Duration.zero,
          ifFirst: (i) => '$i',
        ),
        throwsArgumentError,
      );
    });
  });
}
