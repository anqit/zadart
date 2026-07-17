import 'package:collection/collection.dart';
import 'package:zadart/src/functions/function_utils.dart';
import 'package:zadart/src/nullable/nullable_extensions.dart';

const _dce = DeepCollectionEquality();

/// Extensions on [List].
extension ZadartListExtensions<E> on List<E> {
  /// Returns a list consisting of the unique elements in this list, in
  /// first-encounter order. The [by] parameter selects the value examined for
  /// uniqueness (defaults to the element itself). By default a new list is
  /// returned; set [mutate] to de-duplicate this list in place.
  List<E> unique<By>({ By Function(E)? by, bool mutate = false }) {
    final uniqs = <By>{};
    final list = mutate ? this : [ ...this ];
    final b = by ?? cast;

    return list..retainWhere((e) => uniqs.add(b(e)));
  }

  /// Maps each element with [mapper] and drops the nulls, in one pass.
  List<B> collect<B>(B? Function(E) mapper) =>
      [
        for (final e in map(mapper))
          ?e
      ];

  /// Returns a new list with every element of [other] removed.
  List<E> without(Iterable<E>? other) =>
      other.map((o) {
        if (isEmpty || o.isEmpty) return this;
        final oSet = o.toSet();
        return whereNot(oSet.contains).toList();
      }) ?? this;

  /// Alias for [without].
  List<E> operator -(Iterable<E>? other) => without(other);
}

/// Extensions on [DeepCollectionEquality].
extension ZadartDeepEqualityExtensions on DeepCollectionEquality {
  /// The negation of [equals].
  bool unequal(Object? o1, Object? o2) => !equals(o1, o2);
}

/// Extensions on [Map].
///
/// The copy-on-write operations here ([operator +], [operator -], [merge],
/// [mergeWithKey], [updated], [without]) may, as an optimization, return this
/// map or an argument unchanged rather than a copy. Treat their results as
/// immutable and do not mutate them.
extension ZadartMapExtensions<K, V> on Map<K, V> {
  /// Whether this map deeply equals [other], comparing nested collections by
  /// value.
  bool deepEquals(Object? other) =>
      _dce.equals(this, other);

  /// The negation of [deepEquals].
  bool deepUnequal(Object? other) =>
      _dce.unequal(this, other);

  /// Returns a new map with each value transformed by [mapper].
  Map<K, V2> mapValues<V2>(V2 Function(V) mapper) =>
      mapValuesWithKey((_, v) => mapper(v));

  /// Returns a new map with each value transformed by [mapper], given its key.
  Map<K, V2> mapValuesWithKey<V2>(V2 Function(K, V) mapper) =>
      map((k, v) => MapEntry(k, mapper(k, v)));

  /// Returns the union of this map and [other]; on shared keys, [other] wins.
  Map<K, V> operator +(Map<K, V>? other) =>
      other.map((o) => isEmpty ? o : o.isEmpty ? this : { ...this, ...o, }) ?? this;

  /// Returns a new map with every key present in [other] removed.
  Map<K, V> operator -(Map<K, dynamic>? other) =>
      other.map((o) => (isEmpty || o.isEmpty) ? this :
          {
            for (final MapEntry(:key, :value) in entries)
              if (!o.containsKey(key))
                key: value
          }
      ) ?? this;

  /// Merges this map with [other], resolving shared keys with [merger].
  Map<K, V> merge(Map<K, V> other, V Function(V, V) merger) =>
      mergeWithKey(other, (_, v1, v2) => merger(v1, v2));

  /// Merges this map with [other], resolving shared keys with [merger], which
  /// also receives the key.
  Map<K, V> mergeWithKey(Map<K, V> other, V Function(K, V, V) merger) {
    if(isEmpty) return other;
    if(other.isEmpty) return this;

    final result = { ...this };
    for(final MapEntry(:key, :value) in other.entries) {
      result.update(key, (v) => merger(key, v, value), ifAbsent: () => value);
    }

    return result;
  }

  /// Merges this map with [other] after mapping each side's values to a common
  /// type [R] ([mapper1] for this map, [mapper2] for [other]); shared keys are
  /// resolved with [merger].
  Map<K, R> mergeMap<V2, R>(Map<K, V2> other, R Function(R, R) merger, R Function(V) mapper1, R Function(V2) mapper2) =>
      mergeMapWithKey(other, (_, v1, v2) => merger(v1, v2), (_, v) => mapper1(v), (_, v) => mapper2(v));

  /// Like [mergeMap], but the [merger] and mappers also receive the key.
  Map<K, R> mergeMapWithKey<V2, R>(Map<K, V2> other, R Function(K, R, R) merger, R Function(K, V) mapper1, R Function(K, V2) mapper2) {
    final result = mapValuesWithKey(mapper1);

    for (final MapEntry(:key, :value) in other.entries) {
      result.update(key, (v) => merger(key, v, mapper2(key, value)), ifAbsent: () => mapper2(key, value));
    }

    return result;
  }

  /// Merges this map with [other] into a common value type [R]. Shared keys are
  /// resolved by [merger]; a key unique to this map is mapped by
  /// [ifAbsentInOther], and one unique to [other] by [ifAbsentInThis]. Unlike
  /// [mergeMap], the mapping functions run only on values with unique keys.
  Map<K, R> mergeMapWithDefaults<V2, R>(Map<K, V2> other, R Function(V, V2) merger, R Function(V) ifAbsentInOther, R Function(V2) ifAbsentInThis) =>
      {
        for (final k in keys.followedBy(other.keys).toSet())
          k: containsKey(k)
              ? other.containsKey(k)
                  ? merger(this[k] as V, other[k] as V2)
                  : ifAbsentInOther(this[k] as V)
              : ifAbsentInThis(other[k] as V2)
      };

  /// Returns a new map with only the entries satisfying [predicate].
  Map<K, V> where(bool Function(K, V) predicate) => {
    for(final MapEntry(:key, :value) in entries)
      if (predicate(key, value))
        key: value
  };

  /// Returns a new map without the entries satisfying [predicate].
  Map<K, V> whereNot(bool Function(K, V) predicate) =>
      where((k, v) => !predicate(k, v));

  /// Returns a map with [key] set to [value]. Returns this map unchanged when
  /// [key] already maps to an equal value ([identical] when [forceValueIdentity]
  /// is set, otherwise `==`).
  Map<K, V> updated(K key, V value, { bool forceValueIdentity = false }) {
    if (containsKey(key)) {
      final curr = this[key];
      final bool valueEquals = forceValueIdentity ? identical(curr, value) : curr == value;
      if (valueEquals) {
        return this;
      }
    }
    return { ...this, key: value, };
  }

  /// Returns a map without [key], or this map unchanged when [key] is absent.
  Map<K, V> without(K key) =>
      containsKey(key)
          ? ({ ...this }..remove(key))
          : this;
}

/// Extensions on [MapEntry].
extension ZadartMapEntryExtensions<K, V> on MapEntry<K, V> {
  /// Returns a new entry with the same key and the value transformed by
  /// [mapper].
  MapEntry<K, V2> mapValue<V2>(V2 Function(V) mapper) =>
      MapEntry(key, mapper(value));
}

/// Extensions on [Iterable].
extension ZadartIterableExtensions<E> on Iterable<E> {
  /// The negation of [contains].
  bool doesNotContain(Object? value) =>
    !contains(value);

  /// Builds a map keyed by [keyMapper], with each element as its value. On key
  /// collisions the last element wins.
  Map<K, E> toMap<K>(K Function(E) keyMapper) =>
      toMapWithValues(keyMapper, identity);

  /// Builds a map keyed by [keyMapper] with values produced by [valueMapper].
  /// On key collisions the last element wins.
  Map<K, V> toMapWithValues<K, V>(K Function(E) keyMapper, V Function(E) valueMapper) =>
      fold({}, (acc, e) => acc..[keyMapper(e)] = valueMapper(e));

  /// Whether this iterable deeply equals [other], comparing nested collections
  /// by value.
  bool deepEquals(Object? other) =>
      _dce.equals(this, other);

  /// The negation of [deepEquals].
  bool deepUnequal(Object? other) =>
      _dce.unequal(this, other);

  /// Returns the unique elements of this iterable in first-encounter order.
  /// [by] selects the value examined for uniqueness (defaults to the element
  /// itself). A [Set] with no [by] is returned unchanged.
  Iterable<E> unique<By>({ By Function(E)? by }) =>
      by.whenNull(this).filter((s) => s is Set) ?? _uniq(this, by: by);

  /// Maps each element with [mapper] and drops the nulls.
  Iterable<B> collect<B>(B? Function(E) mapper) =>
    map(mapper).where((b) => b.isNotNull).map((b) => b!);
}

Iterable<E> _uniq<E, By>(Iterable<E> i, { By Function(E)? by }) {
  final uniqs = <By>{};
  final b = by ?? cast;

  return [
    for (final e in i)
      if (uniqs.add(b(e))) e,
    ];
}
