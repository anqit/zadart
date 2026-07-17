import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:zadart/zadart.dart';

void main() {
  group('List.unique', () {
    test('removes duplicates preserving first-encounter order', () {
      expect([3, 1, 3, 2, 1].unique(), [3, 1, 2]);
    });

    test('de-duplicates by a derived key', () {
      final people = [
        (id: 1, name: 'a'),
        (id: 2, name: 'b'),
        (id: 1, name: 'c'),
      ];
      expect(people.unique(by: (p) => p.id).map((p) => p.name), ['a', 'b']);
    });

    test('mutate: true modifies in place and returns the same list', () {
      final list = [1, 1, 2, 3, 3];
      final result = list.unique(mutate: true);
      expect(result, same(list));
      expect(list, [1, 2, 3]);
    });

    test('default leaves the original list intact', () {
      final list = [1, 1, 2];
      final result = list.unique();
      expect(list, [1, 1, 2]);
      expect(result, [1, 2]);
      expect(result, isNot(same(list)));
    });
  });

  group('List.collect', () {
    test('maps and drops nulls in one pass', () {
      expect(['1', 'x', '2'].collect(int.tryParse), [1, 2]);
      expect(<String>[].collect(int.tryParse), <int>[]);
    });
  });

  group('List.without / operator -', () {
    test('removes the given elements', () {
      expect([1, 2, 3, 4].without([2, 4]), [1, 3]);
      expect([1, 2, 3] - [2], [1, 3]);
    });

    test('returns the same instance when other is null or empty', () {
      final list = [1, 2, 3];
      expect(list.without(null), same(list));
      expect(list.without(const []), same(list));
      expect(list - null, same(list));
    });
  });

  group('Map.mapValues / mapValuesWithKey', () {
    test('transform values, keeping keys', () {
      expect({'a': 1, 'b': 2}.mapValues((v) => v * 10), {'a': 10, 'b': 20});
      expect({'a': 1}.mapValuesWithKey((k, v) => '$k$v'), {'a': 'a1'});
    });
  });

  group('Map.operator +', () {
    test('unions two maps', () {
      expect({'a': 1} + {'b': 2}, {'a': 1, 'b': 2});
    });

    test('later map wins on shared keys', () {
      expect({'a': 1} + {'a': 2}, {'a': 2});
    });

    test('returns this when other is null or empty', () {
      final m = {'a': 1};
      expect(m + null, same(m));
      expect(m + <String, int>{}, same(m));
    });

    test('returns other when this is empty', () {
      final other = {'b': 2};
      expect(<String, int>{} + other, same(other));
    });
  });

  group('Map.operator -', () {
    test('removes keys present in the other map', () {
      expect({'a': 1, 'b': 2} - {'b': 0}, {'a': 1});
    });

    test('returns this when other is null or empty', () {
      final m = {'a': 1};
      expect(m - null, same(m));
      expect(m - <String, dynamic>{}, same(m));
    });
  });

  group('Map.merge / mergeWithKey', () {
    test('combines values for shared keys', () {
      expect({'a': 1}.merge({'a': 2, 'b': 3}, (x, y) => x + y),
          {'a': 3, 'b': 3});
    });

    test('mergeWithKey exposes the key to the merger', () {
      expect({'a': 1}.mergeWithKey({'a': 2}, (k, x, y) => k == 'a' ? x + y : 0),
          {'a': 3});
    });

    test('returns the other map when this is empty (and vice versa)', () {
      final other = {'x': 1};
      expect(<String, int>{}.merge(other, (a, b) => a + b), same(other));
      final self = {'y': 2};
      expect(self.merge(<String, int>{}, (a, b) => a + b), same(self));
    });
  });

  group('Map.mergeMap', () {
    test('maps both sides to a common type then merges shared keys', () {
      final result = {'a': 1}.mergeMap<String, String>(
        {'a': 'x', 'b': 'y'},
        (r1, r2) => '$r1$r2',
        (v) => 'i$v',
        (v2) => v2,
      );
      expect(result, {'a': 'i1x', 'b': 'y'});
    });
  });

  group('Map.mergeMapWithDefaults', () {
    test('applies the right mapper per key origin', () {
      final result = {'a': 1, 'b': 2}.mergeMapWithDefaults<int, String>(
        {'b': 20, 'c': 30},
        (v, v2) => 'both:$v/$v2',
        (v) => 'only1:$v',
        (v2) => 'only2:$v2',
      );
      expect(result, {
        'a': 'only1:1',
        'b': 'both:2/20',
        'c': 'only2:30',
      });
    });
  });

  group('Map.where / whereNot', () {
    test('filter entries by key and value', () {
      final m = {'a': 1, 'b': 2, 'c': 3};
      expect(m.where((k, v) => v > 1), {'b': 2, 'c': 3});
      expect(m.whereNot((k, v) => v > 1), {'a': 1});
    });
  });

  group('Map.updated', () {
    test('adds or replaces a key, returning a new map', () {
      final m = {'a': 1};
      final result = m.updated('b', 2);
      expect(result, {'a': 1, 'b': 2});
      expect(m, {'a': 1});
    });

    test('returns the same instance when key exists with an equal value', () {
      final m = {'a': 1};
      expect(m.updated('a', 1), same(m));
    });

    test('returns a new map when the value differs', () {
      final m = {'a': 1};
      final result = m.updated('a', 2);
      expect(result, {'a': 2});
      expect(result, isNot(same(m)));
    });

    test('forceValueIdentity uses identical rather than ==', () {
      final original = 'ab';
      final equalButDistinct = String.fromCharCodes('ab'.codeUnits);
      expect(identical(original, equalButDistinct), isFalse);
      final m = {'k': original};

      // Default equality (==) treats them as equal -> same instance.
      expect(m.updated('k', equalButDistinct), same(m));

      // With forceValueIdentity, distinct instances force a new map.
      final result = m.updated('k', equalButDistinct, forceValueIdentity: true);
      expect(result, isNot(same(m)));
      expect(identical(result['k'], equalButDistinct), isTrue);
    });
  });

  group('Map.without', () {
    test('removes a key, returning a new map', () {
      final m = {'a': 1, 'b': 2};
      expect(m.without('a'), {'b': 2});
      expect(m, {'a': 1, 'b': 2});
    });

    test('returns the same instance when the key is absent', () {
      final m = {'a': 1};
      expect(m.without('z'), same(m));
    });
  });

  group('Map / Iterable deepEquals', () {
    test('compare nested structures by value', () {
      expect({
        'a': [1, 2],
      }.deepEquals({
        'a': [1, 2],
      }), isTrue);
      expect({
        'a': [1, 2],
      }.deepUnequal({
        'a': [1, 3],
      }), isTrue);
      expect([
        [1],
        [2],
      ].deepEquals([
        [1],
        [2],
      ]), isTrue);
    });
  });

  group('DeepCollectionEquality.unequal', () {
    test('is the negation of equals', () {
      const eq = DeepCollectionEquality();
      expect(eq.unequal([1], [2]), isTrue);
      expect(eq.unequal([1], [1]), isFalse);
    });
  });

  group('MapEntry.mapValue', () {
    test('maps the value, keeping the key', () {
      final entry = const MapEntry('k', 2).mapValue((v) => v * 5);
      expect(entry.key, 'k');
      expect(entry.value, 10);
    });
  });

  group('Iterable.doesNotContain', () {
    test('is the negation of contains', () {
      expect([1, 2, 3].doesNotContain(4), isTrue);
      expect([1, 2, 3].doesNotContain(2), isFalse);
    });
  });

  group('Iterable.toMap / toMapWithValues', () {
    test('keys elements by a selector, later entries winning', () {
      expect(['apple', 'avocado', 'banana'].toMap((w) => w[0]),
          {'a': 'avocado', 'b': 'banana'});
    });

    test('toMapWithValues supports a separate value mapper', () {
      expect([1, 2, 3].toMapWithValues((n) => n, (n) => n * n), {1: 1, 2: 4, 3: 9});
    });
  });

  group('Iterable.unique', () {
    test('de-duplicates a plain iterable', () {
      expect([1, 2, 2, 3, 1].unique().toList(), [1, 2, 3]);
    });

    test('returns a Set unchanged when no selector is given', () {
      final set = {1, 2, 3};
      expect(set.unique(), same(set));
    });

    test('de-duplicates by a derived key', () {
      final result = [('a', 1), ('b', 1), ('c', 2)].unique(by: (t) => t.$2);
      expect(result.map((t) => t.$2).toList(), [1, 2]);
    });
  });

  group('Iterable.collect', () {
    test('maps and drops nulls', () {
      expect(['1', 'x', '2'].collect(int.tryParse).toList(), [1, 2]);
    });
  });
}
