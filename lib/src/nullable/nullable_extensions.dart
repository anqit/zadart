import 'package:zadart/src/functions/function_utils.dart';

extension ZadartNullableExtensions<E> on E? {
  B? map<B>(B? Function(E) f) =>
      this != null ? f(this as E) : null;

  Future<B?> asyncMap<B>(Future<B?> Function(E) f) async =>
      this != null ? await f(this as E) : null;

  E? ifNotNull(void Function(E) f, { void Function()? orElse }) =>
      switch (this) {
        E e => e.tap(f),
        _ => orElse.map((oe) {oe(); return null;}),
      };

  Future<E?> asyncIfNotNull(Future<void> Function(E) f, { Future<void> Function()? orElse }) async {
    if (this != null) {
      await f(this as E);
      return this;
    } else {
      if (orElse != null) await orElse();
      return null;
    }
  }

  B? inverse<B>(B? ifNull) =>
      this == null ? ifNull : null;

  B? lazyInverse<B>(B? Function() ifNull) =>
      this == null ? ifNull() : null;

  E? filter(bool Function(E) p) =>
      this != null && p(this as E) ? this : null;

  Future<E?> asyncFilter(Future<bool> Function(E) p) async =>
      this != null && await p(this as E) ? this : null;

  bool get isNull => this == null;

  bool get isNotNull => this != null;
}
