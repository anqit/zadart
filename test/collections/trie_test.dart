import 'package:test/test.dart';
import 'package:zadart/zadart.dart';

void main() {
  Trie<String, int> sample() => Trie<String, int>.fromEntries([
        (['a', 'b'], 1),
        (['a', 'c'], 2),
      ]);

  group('fromEntries / get', () {
    test('looks up values by full key path', () {
      final trie = sample();
      expect(trie.get(['a', 'b']), 1);
      expect(trie.get(['a', 'c']), 2);
    });

    test('returns null for a missing path', () {
      expect(sample().get(['a', 'z']), isNull);
      expect(sample().get(['x']), isNull);
    });

    test('an intermediate node has no value of its own', () {
      expect(sample().get(['a']), isNull);
    });
  });

  group('getTrie / containsKey / operator []', () {
    test('descends into subtrees', () {
      final trie = sample();
      expect(trie.getTrie(['a'])?.get(['b']), 1);
      expect(trie['a']?.get(['c']), 2);
      expect(trie['z'], isNull);
    });

    test('containsKey reflects presence of a node', () {
      final trie = sample();
      expect(trie.containsKey(['a']), isTrue);
      expect(trie.containsKey(['a', 'b']), isTrue);
      expect(trie.containsKey(['a', 'z']), isFalse);
    });
  });

  group('insert', () {
    test('returns a new trie, leaving the original unchanged', () {
      final base = sample();
      final updated = base.insert(['a', 'd'], 3);
      expect(updated.get(['a', 'd']), 3);
      expect(updated.get(['a', 'b']), 1);
      expect(base.get(['a', 'd']), isNull);
    });

    test('inserting an empty path sets the root value', () {
      final trie = Trie<String, int>().insert([], 9);
      expect(trie.get([]), 9);
    });
  });

  group('value / children getters', () {
    test('expose the node contents', () {
      final trie = Trie<String, int>(value: 5);
      expect(trie.value, 5);
      expect(trie.children, isEmpty);
      expect(sample().children.keys, ['a']);
    });
  });

  group('equality', () {
    test('two tries with the same contents are equal', () {
      final a = sample();
      final b = sample();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differing values break equality', () {
      final a = Trie<String, int>.fromEntries([
        (['a'], 1),
      ]);
      final b = Trie<String, int>.fromEntries([
        (['a'], 2),
      ]);
      expect(a, isNot(b));
    });
  });

  group('TrieBuilder', () {
    test('build produces a queryable trie', () {
      final builder = TrieBuilder<String, int>()
        ..insert(['a', 'b'], 1)
        ..insert(['a', 'c'], 2);
      final trie = builder.build();
      expect(trie.get(['a', 'b']), 1);
      expect(trie.get(['a', 'c']), 2);
    });

    test('foldUp folds children before parents', () {
      final builder = TrieBuilder<String, int>()
        ..insert(['a', 'b'], 1)
        ..insert(['a', 'c'], 2);
      // Count every node (root + a + b + c).
      final nodeCount = builder.foldUp<int>(
        (node, children) => 1 + children.values.fold(0, (a, b) => a + b),
      );
      expect(nodeCount, 4);
    });

    test('foldDown visits the root then descends', () {
      final builder = TrieBuilder<String, int>()
        ..insert(['a', 'b'], 1)
        ..insert(['a', 'c'], 2);
      final visited = <String?>[];
      builder.foldDown<int>(0, (depth, key, node) {
        visited.add(key);
        return depth + 1;
      });
      expect(visited.first, isNull); // root is visited first with a null key
      expect(visited, containsAll(['a', 'b', 'c']));
    });
  });
}
