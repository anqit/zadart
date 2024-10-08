import 'dart:convert';

typedef Serializer<From, To> = To Function(From);

typedef JsonSerializer<To> = Serializer<dynamic, To>;

extension SerializerExtensions<F, T> on Serializer<F, T> {
  Serializer<List<F>, List<T>> forList() => (fs) => fs.map(this).toList();

  Serializer<F, T2> map<T2>(T2 Function(T) mapper) => (f) => mapper(this(f));

  Serializer<F2, T> contraMap<F2>(F Function(F2) contraMapper) => (f) => this(contraMapper(f));
}

extension FromMapSerializerExtensions<E> on Serializer<Map<String, dynamic>, E> {
  JsonSerializer<E> jsonSerializer() => contraMap((d) => d as Map<String, dynamic>);
  JsonSerializer<List<E>> jsonListSerializer() => jsonSerializer().forList().contraMap((d) => d as List<dynamic>);
}

bool jsonBoolSerializer(dynamic j) => jsonDecode(j) as bool;
