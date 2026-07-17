/// Orders `bool` values, treating `true` as ordered before `false`.
class BooleanComparable implements Comparable<bool> {
  final bool _thiz;

  const BooleanComparable(this._thiz);

  @override
  int compareTo(bool that) =>
      compare(_thiz, that);

  /// Compares two booleans, ordering `true` before `false`.
  static int compare(bool first, bool second) =>
      first == second ? 0 : first ? -1 : 1;

  /// A [Comparator] over booleans that orders `true` before `false`.
  static const Comparator<bool> comparator = compare;
}

/// Combinators for composing and adapting [Comparator]s.
extension ZadartComparatorExtensions<T> on Comparator<T> {
  /// Returns a comparator with the opposite ordering of this one.
  Comparator<T> reversed() => (t1, t2) => this(t2, t1);

  /// Returns a comparator that falls back to [next] when this one considers
  /// two elements equal.
  Comparator<T> then(Comparator<T> next) =>
      (t1, t2) {
        final first = this(t1, t2);

        return first == 0 ? next(t1, t2) : first;
      };

  /// Chains a tie-breaker comparing by [selector]. Set [reversed] to sort this
  /// step in descending order.
  Comparator<T> thenBy(Comparable Function(T) selector, { bool reversed = false }) =>
      then(reversed ? Comparing<T>().by(selector).reversed() : Comparing<T>().by(selector));

  /// Chains a boolean tie-breaker, ordering `true` before `false` (or the
  /// reverse when [reversed] is set).
  Comparator<T> thenByBool(bool Function(T) selector, { bool reversed = false }) =>
      then(reversed ? Comparing<T>().byBool(selector).reversed()
          : Comparing<T>().byBool(selector));

  /// Chains a tie-breaker comparing [selector]'s values with [comparator].
  Comparator<T> thenWithComparatorBy<F>(F Function(T) selector, Comparator<F> comparator) =>
      then(Comparing<T>().withComparatorBy(selector, comparator));

  /// Adapts this comparator to compare values of type [F] via [map].
  Comparator<F> contraMap<F>(T Function(F) map) =>
      (f1, f2) => this(map(f1), map(f2));
}

/// A builder for [Comparator]s over values of type [T].
class Comparing<T> {
  const Comparing();

  /// A comparator ordering [Comparable] values by their natural ordering.
  static Comparator<T> fromComparable<T extends Comparable<T>>() =>
      (t1, t2) => t1.compareTo(t2);

  /// Orders by the [Comparable] value produced by [selector].
  Comparator<T> by(Comparable Function(T) selector) =>
      (t1, t2) => selector(t1).compareTo(selector(t2));

  /// Orders by the nullable [Comparable] produced by [selector], placing nulls
  /// last.
  Comparator<T> byNullable(Comparable? Function(T) selector) =>
      (t1, t2) =>
          switch ((selector(t1), selector(t2))) {
            (final Comparable a, final Comparable b) => a.compareTo(b),
            (Comparable(), null) => -1,
            (null, Comparable()) => 1,
            _ => 0,
          };

  /// Orders by [selector]'s value using an explicit [comparator].
  Comparator<T> withComparatorBy<F>(F Function(T) selector, Comparator<F> comparator) =>
      (t1, t2) => comparator(selector(t1), selector(t2));

  /// Orders by the boolean [selector], placing `true` before `false`.
  Comparator<T> byBool(bool Function(T) selector) =>
      withComparatorBy(selector, BooleanComparable.comparator);
}
