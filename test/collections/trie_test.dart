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

    test('foldUp folds children before their parents (post-order)', () {
      final builder = TrieBuilder<String, int>()
        ..insert(['a', 'b'], 1)
        ..insert(['a', 'c'], 2);
      final order = <String>[];
      builder.foldUp<int>((node, children) {
        // Label each node by its child keys; leaves have none.
        order.add(children.isEmpty ? 'leaf(${node.value})' : children.keys.join('+'));
        return 1 + children.values.fold(0, (a, b) => a + b);
      });
      // Leaves b and c fold first, then their parent a, then the root.
      expect(order, ['leaf(1)', 'leaf(2)', 'b+c', 'a']);
    });

    test('foldDown threads the accumulator through nodes in pre-order', () {
      final builder = TrieBuilder<String, int>()
        ..insert(['a', 'b'], 1)
        ..insert(['a', 'c'], 2);
      // The returned accumulator is threaded through every node; record each
      // key in the order it is visited.
      final order = builder.foldDown<List<String?>>(
        <String?>[],
        (acc, key, node) => [...acc, key],
      );
      // Root first (null key), then depth-first into a and its children.
      expect(order, [null, 'a', 'b', 'c']);
    });
  });
}
