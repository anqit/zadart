import 'dart:async';

extension ZadartNullableExtensions<E> on E? {
  B? map<B>(B? Function(E) f) =>
      isNotNull ? f(this as E) : null;

  Future<B?> asyncMap<B>(Future<B?> Function(E) f) async =>
      isNotNull ? await f(this as E) : null;

  void ifNotNull(void Function(E) f, { void Function()? orElse }) =>
      isNotNull ? f(this as E) : orElse?.call();

  Future<void> asyncIfNotNull(Future<void> Function(E) f, { Future<void> Function()? orElse }) async =>
      isNotNull ? await f(this as E) : orElse?.call();

  Future<void> asyncIfNull(Future<void> Function() f) async =>
      isNull ? await f() : null;

  B? ifNull<B>(B? ifNull) =>
      isNull ? ifNull : null;

  B? lazyIfNull<B>(B? Function() ifNull) =>
      isNull ? ifNull() : null;

  E? filter(bool Function(E) p) =>
      isNotNull && p(this as E) ? this : null;

  Future<E?> asyncFilter(Future<bool> Function(E) p) async =>
      isNotNull && await p(this as E) ? this : null;

  bool get isNull => this == null;

  bool get isNotNull => !isNull;
}
