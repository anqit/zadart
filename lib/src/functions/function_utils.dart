/// A function that takes no arguments and does nothing.
void noop() {}

/// A single-argument function that does nothing.
void noop1(_) {}

/// Returns its argument unchanged.
E identity<E>(E e) => e;

/// Casts [e] to type [To]. This is an unchecked cast that throws at runtime if
/// [e] is not a [To].
To cast<To, From>(From e) => e as To;

/// Extensions available on values of any type.
extension FunctionalExtensions<E> on E {
  /// Runs [f] on this value for its side effect and returns this value, so it
  /// can be dropped inline into a chain.
  E tap(void Function(E) f) {
    f(this);
    return this;
  }
}
