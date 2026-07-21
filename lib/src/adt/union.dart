/// Matches [scrutiny] against [I1]/[I2], calling the matched callback — or
/// [otherwise] when a matched type's callback is absent; [ifNull] handles null.
/// Any other value throws an [ArgumentError].
T match2<T, I1, I2>(dynamic scrutiny, {
  T Function(I1)? ifFirst,
  T Function(I2)? ifSecond,
  T Function()? ifNull,
  T Function(dynamic)? otherwise,
}) =>
    switch (scrutiny) {
      I1 i1 when ifFirst != null => ifFirst(i1),
      I1 i1 when otherwise != null => otherwise(i1),
      I2 i2 when ifSecond != null => ifSecond(i2),
      I2 i2 when otherwise != null => otherwise(i2),
      null when ifNull != null => ifNull(),
      _ => throw ArgumentError('match2: no handler for ${scrutiny.runtimeType}'),
    };

/// Like [match2], matching [scrutiny] against three types.
T match3<T, I1, I2, I3>(dynamic scrutiny, {
  T Function(I1)? ifFirst,
  T Function(I2)? ifSecond,
  T Function(I3)? ifThird,
  T Function()? ifNull,
  T Function(dynamic)? otherwise,
}) =>
    switch (scrutiny) {
      I1 i1 when ifFirst != null => ifFirst(i1),
      I1 i1 when otherwise != null => otherwise(i1),
      I2 i2 when ifSecond != null => ifSecond(i2),
      I2 i2 when otherwise != null => otherwise(i2),
      I3 i3 when ifThird != null => ifThird(i3),
      I3 i3 when otherwise != null => otherwise(i3),
      null when ifNull != null => ifNull(),
      _ => throw ArgumentError('match3: no handler for ${scrutiny.runtimeType}'),
    };

/// Like [match2], matching [scrutiny] against four types.
T match4<T, I1, I2, I3, I4>(dynamic scrutiny, {
  T Function(I1)? ifFirst,
  T Function(I2)? ifSecond,
  T Function(I3)? ifThird,
  T Function(I4)? ifFourth,
  T Function()? ifNull,
  T Function(dynamic)? otherwise,
}) =>
    switch (scrutiny) {
      I1 i1 when ifFirst != null => ifFirst(i1),
      I1 i1 when otherwise != null => otherwise(i1),
      I2 i2 when ifSecond != null => ifSecond(i2),
      I2 i2 when otherwise != null => otherwise(i2),
      I3 i3 when ifThird != null => ifThird(i3),
      I3 i3 when otherwise != null => otherwise(i3),
      I4 i4 when ifFourth != null => ifFourth(i4),
      I4 i4 when otherwise != null => otherwise(i4),
      null when ifNull != null => ifNull(),
      _ => throw ArgumentError('match4: no handler for ${scrutiny.runtimeType}'),
    };

/// Like [match2], matching [scrutiny] against five types.
T match5<T, I1, I2, I3, I4, I5>(dynamic scrutiny, {
  T Function(I1)? ifFirst,
  T Function(I2)? ifSecond,
  T Function(I3)? ifThird,
  T Function(I4)? ifFourth,
  T Function(I5)? ifFifth,
  T Function()? ifNull,
  T Function(dynamic)? otherwise,
}) =>
    switch (scrutiny) {
      I1 i1 when ifFirst != null => ifFirst(i1),
      I1 i1 when otherwise != null => otherwise(i1),
      I2 i2 when ifSecond != null => ifSecond(i2),
      I2 i2 when otherwise != null => otherwise(i2),
      I3 i3 when ifThird != null => ifThird(i3),
      I3 i3 when otherwise != null => otherwise(i3),
      I4 i4 when ifFourth != null => ifFourth(i4),
      I4 i4 when otherwise != null => otherwise(i4),
      I5 i5 when ifFifth != null => ifFifth(i5),
      I5 i5 when otherwise != null => otherwise(i5),
      null when ifNull != null => ifNull(),
      _ => throw ArgumentError('match5: no handler for ${scrutiny.runtimeType}'),
    };
