void noop() {}

void noop1(_) {}

E identity<E>(E e) => e;

To cast<To, From>(From e) => e as To;

extension FunctionalExtensions<E> on E {
  E tap(void Function(E) f) {
    f(this);
    return this;
  }
}
