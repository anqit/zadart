

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

  factory Comparing.by(dynamic Function(T) selector) => ComparingImpl(selector);

  Comparing<T> withComparator(Comparator<dynamic> comparator) => switch(this) {
    ComparingImpl(:final selector) =>
        ComparatorComparing(selector, comparator),
    ChainedComparing(:final first, :final second) =>
        ChainedComparing(first.withComparator(comparator), second.withComparator(comparator)),
    ReversedComparing(:final wrapped) =>
        ReversedComparing(wrapped.withComparator(comparator)),
    ComparatorComparing(:final selector) =>
        ComparatorComparing(selector, comparator),
  };

  Comparing<T> thenComparing(Comparing<T> next, { bool reversed = false }) =>
      reversed ? ChainedComparing(this, next).reversed() : ChainedComparing(this, next);

  Comparing<T> then<F>(F Function(T) selector, { bool reversed = false }) =>
      thenComparing(Comparing.by(selector), reversed: reversed);

  Comparing<T> reversed() => switch (this) {
    ReversedComparing(:final wrapped) => wrapped,
    Comparing<T> c => ReversedComparing(c),
  };
}

class ComparingImpl<T> extends Comparing<T> {
  final dynamic Function(T) selector;

  const ComparingImpl(this.selector);

  @override
  int call(T t1, T t2) {
    final first = selector(t1);
    final second = selector(t2);

    return switch (first) {
      Comparable() => first.compareTo(second),
      bool() => BooleanComparable.compare(first, second as bool),
      _ => throw 'comparison not available',
    };
  }
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
  int call(T t1, T t2) =>
      wrapped(t2, t1);
}

class ComparatorComparing<T> extends Comparing<T> {
  final dynamic Function(T) selector;
  final Comparator<dynamic> comparator;

  const ComparatorComparing(this.selector, this.comparator);

  @override
  int call(T t1, T t2) => comparator(selector(t1), selector(t2));
}
