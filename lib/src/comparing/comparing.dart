class BooleanComparable implements Comparable<bool> {
  final bool thiz;

  const BooleanComparable(this.thiz);

  @override
  int compareTo(bool that) =>
      compare(thiz, that);

  static int compare(bool first, bool second) =>
      first == second ? 0 : first == true ? -1 : 1;

  static Comparator<bool> comparator = compare;
}

extension ZadartComparatorExtensions<T> on Comparator<T> {
  Comparator<T> reversed() => (t1, t2) => this(t2, t1);

  Comparator<T> then(Comparator<T> next) =>
      (t1, t2) {
        final first = this(t1, t2);

        return first == 0 ? next(t1, t2) : first;
      };

  Comparator<T> thenBy<F extends Comparable<F>>(F Function(T) selector, { bool reversed = false }) =>
      then(reversed ? Comparing<T>().by(selector).reversed() : Comparing<T>().by(selector));

  Comparator<T> thenByBool(bool Function(T) selector, { bool reversed = false }) =>
      then(reversed ? Comparing<T>().byBool(selector).reversed()
          : Comparing<T>().byBool(selector));

  Comparator<T> thenWithComparatorBy<F>(F Function(T) selector, Comparator<F> comparator) =>
      then(Comparing<T>().withComparatorBy(selector, comparator));

  Comparator<F> contraMap<F>(T Function(F) map) =>
      (f1, f2) => this(map(f1), map(f2));
}

class Comparing<T> {
  const Comparing();

  static Comparator<T> fromComparable<T extends Comparable<T>>() =>
      (t1, t2) => t1.compareTo(t2);

  Comparator<T> by<F extends Comparable<F>>(F Function(T) selector) =>
      (t1, t2) => Comparing.fromComparable<F>()(selector(t1), selector(t2));

  Comparator<T> byNullable<F extends Comparable<F>>(F? Function(T) selector) =>
      (t1, t2) =>
          switch ((selector(t1), selector(t2))) {
            (F f1, F f2) => Comparing.fromComparable<F>()(f1, f2),
            (final _?, null) => -1,
            (null, final _?) => 1,
            _ => 0,
          };

  Comparator<T> withComparatorBy<F>(F Function(T) selector, Comparator<F> comparator) =>
      (t1, t2) => comparator(selector(t1), selector(t2));

  Comparator<T> byBool(bool Function(T) selector) =>
      withComparatorBy(selector, BooleanComparable.comparator);
}
