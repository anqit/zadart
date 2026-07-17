import 'dart:collection';

import 'package:zadart/src/collections/collection_extensions.dart';

/// An immutable trie mapping paths of keys ([List]<[K]>) to values of type [V].
class Trie<K, V> {
  final V? _value;
  final Map<K, Trie<K, V>> _children;

  Trie({this._value, Map<K, Trie<K, V>> children = const {}})
      : _children = UnmodifiableMapView(children);

  /// Builds a trie from `(path, value)` pairs.
  factory Trie.fromEntries(Iterable<(List<K>, V?)> entries) {
    final b = TrieBuilder<K, V>();
    for (final (keys, value) in entries) {
      b.insert(keys, value);
    }
    return b.build();
  }

  /// The value stored at this node, if any.
  V? get value => _value;

  /// The child subtries of this node, keyed by their next path element.
  Map<K, Trie<K, V>> get children => _children;

  /// The child subtrie reached by [key], or null if absent.
  Trie<K, V>? operator [](K key) => _children[key];

  /// The value stored at [keys], or null if the path has no value.
  V? get(List<K> keys) =>
      switch (keys) {
        [] => value,
        [ final first, ... final rest ] => this[first]?.get(rest),
      };

  /// The subtrie rooted at [keys], or null if the path is absent.
  Trie<K, V>? getTrie(List<K> keys) =>
      switch (keys) {
        [] => this,
        [ final first, ... final rest ] => this[first]?.getTrie(rest),
      };

  /// Whether a node exists at [keys] (regardless of whether it holds a value).
  bool containsKey(List<K> keys) => getTrie(keys) != null;

  /// Returns a new trie with [value] stored at [keys], leaving this one
  /// unchanged.
  Trie<K, V> insert(List<K> keys, V? value) =>
      switch (keys) {
        [] => Trie(value: value, children: _children),
        [ final first, ... final rest ] =>
            Trie(
              value: _value,
              children: _children.updated(first, (this[first] ?? Trie()).insert(rest, value)),
            ),
      };

  @override
  int get hashCode =>
      Object.hash(_value, Object.hashAllUnordered([
        for (final MapEntry(:key, :value) in _children.entries)
          Object.hash(key, value),
      ]));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other case Trie<K, V> o) {
      return _value == o._value && _children.deepEquals(o._children);
    } else {
      return false;
    }
  }
}

/// A mutable builder for constructing a [Trie].
class TrieBuilder<K, V> {
  V? value;
  final Map<K, TrieBuilder<K, V>> _children = {};

  TrieBuilder([this.value]);

  /// Stores [value] at [keys], creating intermediate nodes as needed.
  void insert(List<K> keys, V? value) {
    var node = this;
    for (final key in keys) {
      node = node._children.putIfAbsent(key, TrieBuilder<K, V>.new);
    }
    node.value = value;
  }

  /// Folds over the nodes in pre-order (root first), threading the accumulator
  /// through every node and returning the final result. [f] receives the
  /// current accumulator, the key leading to the node (null for the root), and
  /// the node itself.
  F foldDown<F>(F initial, F Function(F, K?, TrieBuilder<K, V>) f) {
    F go(F acc, K? k, TrieBuilder<K, V> node) {
      var next = f(acc, k, node);
      for (final MapEntry(:key, :value) in node._children.entries) {
        next = go(next, key, value);
      }
      return next;
    }
    return go(initial, null, this);
  }

  /// Folds over the nodes bottom-up: [f] receives each node together with a map
  /// of its already-folded children.
  F foldUp<F>(F Function(TrieBuilder<K, V>, Map<K, F> children) f) {
    F go(TrieBuilder<K, V> node) =>
        f(node, {
          for (final MapEntry(:key, :value) in node._children.entries)
            key: go(value),
        });

    return go(this);
  }

  /// Builds an immutable [Trie] from this builder's current state.
  Trie<K, V> build() =>
      Trie(value: value, children: {
        for (final MapEntry(:key, value: child) in _children.entries)
          key: child.build(),
      });
}
