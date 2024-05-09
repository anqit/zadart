extension ZadartFutureExtensions<E> on Future<E> {
  Future<E> thenTap(void Function(E) tap) =>
      then((e) {
        tap(e);

        return e;
      });
}