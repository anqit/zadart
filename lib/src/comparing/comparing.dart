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

sealed class Comparing<T> {
  int call(T t1, T t2);

  const Comparing();
  
  static Comparing<T> fromComparable<T extends Comparable<T>>() =>
      ComparableComparing();

  static Comparing<T> by<T, F extends Comparable<F>>(F Function(T) selector) =>
      SelectorComparing(selector);

  static Comparing<T> withComparator<T>(Comparator<T> comparator) =>
      WithComparatorComparing(comparator);
  
  static Comparing<T> withComparatorBy<T, F>(F Function(T) selector, Comparator<F> comparator) =>
      SelectorWithComparatorComparing(selector, comparator);

  Comparing<T> thenBy<F extends Comparable<F>>(F Function(T) selector, { bool reversed = false }) =>
      thenComparing(Comparing.by(selector), reversed: reversed);

  Comparing<T> thenWithComparator(Comparator<T> comparator, { bool reversed = false }) =>
      thenComparing(Comparing.withComparator(comparator), reversed: reversed);

  Comparing<T> thenWithComparatorBy<F>(F Function(T) selector, Comparator<F> comparator, { bool reversed = false }) =>
      thenComparing(Comparing.withComparatorBy(selector, comparator), reversed: reversed);

  Comparing<T> thenComparing(Comparing<T> next, { bool reversed = false }) =>
      reversed ? ChainedComparing(this, next).reversed() : ChainedComparing(this, next);

  Comparing<T> reversed() => switch (this) {
    ReversedComparing(:final wrapped) => wrapped,
    Comparing<T> c => ReversedComparing(c),
  };
}

class ChainedComparing<T> extends Comparing<T> {
  final Comparing<T> first;
  final Comparing<T> second;

  const ChainedComparing(this.first, this.second);

  @override
  int call(T t1, T t2) {
    final f = first(t1, t2);

    return f == 0 ? second.call(t1, t2) : f;
  }
}

class ReversedComparing<T> extends Comparing<T> {
  final Comparing<T> wrapped;

  const ReversedComparing(this.wrapped);

  @override
  int call(T t1, T t2) => wrapped(t2, t1);
}

class ComparableComparing<T extends Comparable<T>> extends Comparing<T> {
  @override
  int call(T t1, T t2) => t1.compareTo(t2);
}

class SelectorComparing<T, F extends Comparable<F>> extends Comparing<T> {
  final F Function(T) selector;

  const SelectorComparing(this.selector);

  @override
  int call(T t1, T t2) => selector(t1).compareTo(selector(t2));
}

class WithComparatorComparing<T> extends Comparing<T> {
  final Comparator<T> comparator;

  const WithComparatorComparing(this.comparator);

  @override
  int call(T t1, T t2) => comparator(t1, t2);
}

class SelectorWithComparatorComparing<T, F> extends Comparing<T> {
  final F Function(T) selector;
  final Comparator<F> comparator;

  const SelectorWithComparatorComparing(this.selector, this.comparator);

  @override
  int call(T t1, T t2) => comparator(selector(t1), selector(t2));
}
