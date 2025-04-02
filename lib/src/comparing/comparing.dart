class BooleanComparable implements Comparable<bool> {
  final bool thiz;
  final bool trueFirst;

  const BooleanComparable(this.thiz, [ this.trueFirst = true ]);

  @override
  int compareTo(bool that) =>
      compare(thiz, that, trueFirst);

  static int compare(bool first, bool second, [ bool trueFirst = true ]) =>
      first == second ? 0 : first == trueFirst ? -1 : 1;
}

extension <T> on Comparator<T> {
  Comparator<T> reversed() => (t1, t2) => this(t2, t1);

  Comparator<T> then(Comparator<T> next) =>
      (t1, t2) {
        final first = this(t1, t2);

        return first == 0 ? next(t1, t2) : first;
      };

  Comparator<T> thenBy<F extends Comparable<F>>(F Function(T) selector, { bool reversed = false }) =>
      then(reversed ? Comparing.by(selector).reversed() : Comparing.by(selector));

  Comparator<T> thenWithComparatorBy<F>(F Function(T) selector, Comparator<F> comparator, { bool reversed = false }) =>
      then(reversed ? Comparing.withComparatorBy(selector, comparator).reversed() : Comparing.withComparatorBy(selector, comparator));
}

sealed class Comparing<T> {
  const Comparing();

  static Comparator<T> fromComparable<T extends Comparable<T>>() =>
      (t1, t2) => t1.compareTo(t2);

  static Comparator<T> by<T, F extends Comparable<F>>(F Function(T) selector) =>
      (t1, t2) => selector(t1).compareTo(selector(t2));


  static Comparator<T> withComparatorBy<T, F>(F Function(T) selector, Comparator<F> comparator) =>
      (t1, t2) => comparator(selector(t1), selector(t2));
}
