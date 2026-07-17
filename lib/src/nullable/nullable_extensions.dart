import 'dart:async';

/// Extensions for working with nullable values without explicit null checks.
extension ZadartNullableExtensions<E> on E? {
  /// Transforms a non-null value with [f]; returns null when this is null.
  B? map<B>(B? Function(E) f) =>
      isNotNull ? f(this as E) : null;

  /// Asynchronous [map].
  Future<B?> asyncMap<B>(Future<B?> Function(E) f) async =>
      isNotNull ? await f(this as E) : null;

  /// Runs [f] on a non-null value, otherwise calls [orElse] if provided.
  void ifNotNull(void Function(E) f, { void Function()? orElse }) =>
      isNotNull ? f(this as E) : orElse?.call();

  /// Asynchronous [ifNotNull].
  Future<void> asyncIfNotNull(Future<void> Function(E) f, { Future<void> Function()? orElse }) async =>
      isNotNull ? await f(this as E) : orElse?.call();

  /// Returns [value] when this is null, and null when this is non-null.
  ///
  /// This is the null-side counterpart to [map], not a coalescing operator —
  /// use `??` to fall back to a value when this is null.
  B? whenNull<B>(B? value) =>
      isNull ? value : null;

  /// Lazily returns `value()` when this is null, and null when non-null.
  ///
  /// The null-side counterpart to [map]; see [whenNull].
  B? whenNullGet<B>(B? Function() value) =>
      isNull ? value() : null;

  /// Runs [f] when this is null.
  Future<void> asyncIfNull(Future<void> Function() f) async =>
      isNull ? await f() : null;

  /// Returns this value when it is non-null and satisfies [p]; otherwise null.
  E? filter(bool Function(E) p) =>
      isNotNull && p(this as E) ? this : null;

  /// Asynchronous [filter].
  Future<E?> asyncFilter(Future<bool> Function(E) p) async =>
      isNotNull && await p(this as E) ? this : null;

  /// Whether this value is null.
  bool get isNull => this == null;

  /// Whether this value is non-null.
  bool get isNotNull => !isNull;
}
