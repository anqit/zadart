void noop() {}

void noop1(_) {}

E identity<E>(E e) => e;

By identityCast<By, E>(E e) => e as By;

extension FunctionalExtensions<E> on E {
  E tap(void Function(E) f) {
    f(this);
    return this;
  }
}
