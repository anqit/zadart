/// A function that converts a value of type [From] into one of type [To].
typedef Serializer<From, To> = To Function(From);

/// A [Serializer] whose input is the dynamic value produced by `jsonDecode`.
typedef JsonSerializer<To> = Serializer<dynamic, To>;

/// Combinators for composing [Serializer]s.
extension SerializerExtensions<F, T> on Serializer<F, T> {
  /// Lifts this serializer to operate over a list of inputs.
  Serializer<List<F>, List<T>> forList() => (fs) => fs.map(this).toList();

  /// Post-processes this serializer's output with [mapper].
  Serializer<F, T2> map<T2>(T2 Function(T) mapper) => (f) => mapper(this(f));

  /// Pre-processes this serializer's input with [contraMapper].
  Serializer<F2, T> contraMap<F2>(F Function(F2) contraMapper) => (f) => this(contraMapper(f));
}

/// Combinators for serializers that build a value from a JSON map.
extension FromMapSerializerExtensions<E> on Serializer<Map<String, dynamic>, E> {
  /// Adapts this serializer to consume the dynamic result of `jsonDecode`.
  JsonSerializer<E> jsonSerializer() => contraMap((d) => d as Map<String, dynamic>);

  /// Adapts this serializer to consume a decoded top-level JSON array.
  JsonSerializer<List<E>> jsonListSerializer() => jsonSerializer().forList().contraMap((d) => d as List<dynamic>);
}
