extension NullableExtensions<E> on E? {
  B? map<B>(B? Function(E) f) =>
      this != null ? f(this as E) : null;

  void ifNotNull(void Function(E) f) => map(f);

  B? inverse<B>(B? ifNull) =>
      this == null ? ifNull : null;

  E? filter(bool Function(E) p) =>
      this != null && p(this as E) ? this : null;
}