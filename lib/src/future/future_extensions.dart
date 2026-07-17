/// Extensions on [Future].
extension ZadartFutureExtensions<E> on Future<E> {
  /// Runs [tap] on the resolved value for its side effect and passes the value
  /// through unchanged.
  Future<E> thenTap(void Function(E) tap) =>
      then((e) {
        tap(e);

        return e;
      });
}
