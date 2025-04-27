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
      then(reversed ? Comparing.by(selector).reversed() : Comparing.by(selector));

  Comparator<T> thenByBool(bool Function(T) selector, { bool reversed = false }) =>
      then(reversed ? Comparing.withComparatorBy(selector, BooleanComparable.comparator).reversed()
          : Comparing.withComparatorBy(selector, BooleanComparable.comparator));

  Comparator<T> thenWithComparatorBy<F>(F Function(T) selector, Comparator<F> comparator) =>
      then(Comparing.withComparatorBy(selector, comparator));

  Comparator<F> contraMap<F>(T Function(F) map) =>
      (f1, f2) => this(map(f1), map(f2));
}

sealed class Comparing {
  const Comparing();

  static Comparator<T> fromComparable<T extends Comparable<T>>() =>
      (t1, t2) => t1.compareTo(t2);

  static Comparator<T> by<T, F extends Comparable<F>>(F Function(T) selector) =>
      (t1, t2) => selector(t1).compareTo(selector(t2));


  static Comparator<T> withComparatorBy<T, F>(F Function(T) selector, Comparator<F> comparator) =>
      (t1, t2) => comparator(selector(t1), selector(t2));
}
