import 'package:zadart/zadart.dart';

/// Examples for the immutable [Trie] and its [TrieBuilder].
void main() {
  // Build a trie from key-path / value pairs.
  final routes = Trie<String, String>.fromEntries([
    (['users'], 'list users'),
    (['users', 'new'], 'create user'),
    (['posts', 'draft'], 'edit draft'),
  ]);

  // Look up a value by its full key path.
  print(routes.get(['users', 'new'])); // create user
  print(routes.get(['users', 'missing'])); // null

  // Check for a path, and descend into a subtree.
  print(routes.containsKey(['posts', 'draft'])); // true
  print(routes.getTrie(['users'])?.get(['new'])); // create user

  // Tries are immutable: `insert` returns a new trie, leaving the original as-is.
  final updated = routes.insert(['posts', 'publish'], 'publish post');
  print(updated.get(['posts', 'publish'])); // publish post
  print(routes.get(['posts', 'publish'])); // null

  // For bulk construction, use TrieBuilder then `build`.
  final builder = TrieBuilder<String, int>()
    ..insert(['a', 'b'], 1)
    ..insert(['a', 'c'], 2);
  final counts = builder.build();
  print(counts.get(['a', 'b'])); // 1
}
