import 'package:collection/collection.dart';
import 'package:zadart/src/functions/function_utils.dart';
import 'package:zadart/src/nullable/nullable_extensions.dart';

const _dce = DeepCollectionEquality();

// extensions on lists
extension ZadartListExtensions<E> on List<E> {
  /// Returns a new list consisting of the unique elements in this list, in first-encounter order
  /// The [by] parameter can be used to provide a function to determine what to examine when determining
  /// uniqueness, otherwise standard equality is used.
  /// By default, this will return a new list, but [mutate] can be used change the list in place instead
  List<E> unique<By>({ By Function(E)? by, bool mutate = false }) {
    final uniqs = <By>{};
    final list = mutate ? this : [ ...this ];
    final b = by ?? identityCast;
    return list..retainWhere((e) => uniqs.add(b(e)));
  }
}

extension ZadartDeepEqualityExtensions on DeepCollectionEquality {
  bool unequal(Object? o1, Object? o2) => !equals(o1, o2);
}

extension ZadartMapExtensions<K, V> on Map<K, V> {
  bool deepEquals(Object? other) =>
      _dce.equals(this, other);

  bool deepUnequal(Object? other) =>
      _dce.unequal(this, other);

  Map<K, V2> mapValues<V2>(V2 Function(V) mapper) =>
      mapValuesWithKey((_, v) => mapper(v));

  Map<K, V2> mapValuesWithKey<V2>(V2 Function(K, V) mapper) =>
      map((k, v) => MapEntry(k, mapper(k, v)));

  Map<K, V> operator +(Map<K, V>? other) =>
      other.map((o) => { ...this, ...o, }) ?? this;

  Map<K, V> merge(Map<K, V> other, V Function(V, V) merger) =>
      mergeWithKey(other, (_, v1, v2) => merger(v1, v2));

  Map<K, V> mergeWithKey(Map<K, V> other, V Function(K, V, V) merger) {
    final result = { ...this };
    for(final MapEntry(:key, :value) in other.entries) {
      result.update(key, (v) => merger(key, v, value), ifAbsent: () => value);
    }

    return result;
  }
  // mergeWithDefaultMappers(other, merger, identity, identity);

  // merge this map with another, after mapping each map's values to the common type R using the mappers,
  // and using the given `merger` function for keys that occur in both maps
  Map<K, R> mergeMap<V2, R>(Map<K, V2> other, R Function(R, R) merger, R Function(V) mapper1, R Function(V2) mapper2) =>
      mergeMapWithKey(other, (_, v1, v2) => merger(v1, v2), (_, v) => mapper1(v), (_, v) => mapper2(v));

  Map<K, R> mergeMapWithKey<V2, R>(Map<K, V2> other, R Function(K, R, R) merger, R Function(K, V) mapper1, R Function(K, V2) mapper2) {
    final result = mapValuesWithKey(mapper1);

    for (final MapEntry(:key, :value) in other.entries) {
      result.update(key, (v) => merger(key, v, mapper2(key, value)), ifAbsent: () => mapper2(key, value));
    }

    return result;
  }

  // merge this map with another map with the same key type (but potentially different value types)
  // if both maps contain the same key, the resulting map's value for that key is determined by the calling `merger` on the two values, with this map's value
  // as the first operand, and the other's as the 2nd
  // if a key appears in only one map or the other, the respective `ifAbsent...` mapping function is used to determine the value.
  // this is similar to `mergeMap`, but differs in that the mapping functions are only called on values with keys unique to one map
  Map<K, R> mergeMapWithDefaults<V2, R>(Map<K, V2> other, R Function(V, V2) merger, R Function(V) ifAbsentInOther, R Function(V2) ifAbsentInThis) =>
      {
        for (final k in keys.followedBy(other.keys).toSet())
          k: containsKey(k) ?
          (other.containsKey(k) ?
          merger(this[k] as V, other[k] as V2) : ifAbsentInOther(this[k] as V)
          ) : ifAbsentInThis(other[k] as V2)
      };

  Map<K, V> where(bool Function(K, V) predicate) => {
    for(final MapEntry(:key, :value) in entries)
      if (predicate(key, value))
        key: value
  };

  Map<K, V> whereNot(bool Function(K, V) predicate) =>
      where((k, v) => !predicate(k, v));
}

extension ZadartMapEntryExtensions<K, V> on MapEntry<K, V> {
  MapEntry<K, V2> mapValue<V2>(V2 Function(V) mapper) =>
      MapEntry(key, mapper(value));
}

extension ZadartIterableExtensions<E> on Iterable<E> {
  Map<K, E> toMap<K>(K Function(E) keyMapper) =>
      toMapVm(keyMapper);

  // TODO figure out how to not need two toMaps:
  // how to infer V == E if valueMapper is not provided?
  Map<K, V> toMapVm<K, V>(K Function(E) keyMapper, [V Function(E)? valueMapper]) =>
      fold({}, (acc, e) => {
        ...acc,
        keyMapper(e): (valueMapper ?? identityCast)(e)
      });

  bool deepEquals(Object? other) =>
      _dce.equals(this, other);

  bool deepUnequal(Object? other) =>
      _dce.unequal(this, other);

  Iterable<E> unique<By>({ By Function(E)? by, bool mutate = false }) =>
      by.inverse(this).filter((s) => s is Set) ?? _uniq(this, by: by, mutate: mutate);
}

Iterable<E> _uniq<E, By>(Iterable<E> i, { By Function(E)? by, bool mutate = false }) {
  final uniqs = <By>{};
  final b = by ?? identityCast;

  return [
    for (final e in i)
      if (uniqs.add(b(e))) e,
    ];
}
