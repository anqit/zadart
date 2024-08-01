extension ZadartNullableExtensions<E> on E? {
  B? map<B>(B? Function(E) f) =>
      this != null ? f(this as E) : null;

  E? ifNotNull(void Function(E) f, { void Function()? orElse }) {
    if (this != null) {
      f(this as E);
      return this;
    } else {
      if (orElse != null) orElse();
      return null;
    }
  }

  B? inverse<B>(B? ifNull) =>
      this == null ? ifNull : null;

  E? filter(bool Function(E) p) =>
      this != null && p(this as E) ? this : null;
}
