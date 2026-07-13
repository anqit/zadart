import 'dart:collection';

import 'package:zadart/src/collections/collection_extensions.dart';

class Trie<K, V> {
  final V? _value;
  final Map<K, Trie<K, V>> _children;

  Trie({this._value, Map<K, Trie<K, V>> children = const {}})
      : _children = UnmodifiableMapView(children);

  factory Trie.fromEntries(Iterable<(List<K>, V?)> entries) {
    final b = TrieBuilder<K, V>();
    for (final (keys, value) in entries) {
      b.insert(keys, value);
    }
    return b.build();
  }

  V? get value => _value;

  Map<K, Trie<K, V>> get children => _children;

  Trie<K, V>? operator [](K key) => _children[key];

  V? get(List<K> keys) =>
      switch (keys) {
        [] => value,
        [ final first, ... final rest ] => this[first]?.get(rest),
      };

  Trie<K, V>? getTrie(List<K> keys) =>
      switch (keys) {
        [] => this,
        [ final first, ... final rest ] => this[first]?.getTrie(rest),
      };

  bool containsKey(List<K> keys) => getTrie(keys) != null;

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

class TrieBuilder<K, V> {
  V? value;
  final Map<K, TrieBuilder<K, V>> _children = {};

  TrieBuilder([this.value]);

  void insert(List<K> keys, V? value) {
    var node = this;
    for (final key in keys) {
      node = node._children.putIfAbsent(key, TrieBuilder<K, V>.new);
    }
    node.value = value;
  }

  void foldDown<F>(F initial, F Function(F, K?, TrieBuilder<K, V>) f) {
    void go(F acc, K? k, TrieBuilder<K, V> node) {
      final next = f(acc, k, node);
      for (final MapEntry(:key, :value) in node._children.entries) {
        go(next, key, value);
      }
    }
    go(initial, null, this);
  }

  F foldUp<F>(F Function(TrieBuilder<K, V>, Map<K, F> children) f) {
    F go(TrieBuilder<K, V> node) =>
        f(node, {
          for (final MapEntry(:key, :value) in node._children.entries)
            key: go(value),
        });

    return go(this);
  }

  Trie<K, V> build() =>
      Trie(value: value, children: {
        for (final MapEntry(:key, value: child) in _children.entries)
          key: child.build(),
      });
}
