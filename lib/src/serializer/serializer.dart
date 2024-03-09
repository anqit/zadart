typedef Serializer<From, To> = To Function(From);

typedef JsonSerializer<To> = Serializer<dynamic, To>;

extension SerializerExtensions<F, T> on Serializer<F, T> {
  Serializer<List<F>, List<T>> many() => (fs) => fs.map(this).toList();
}

extension JsonSerializerExtensions<To> on JsonSerializer<To> {
  JsonSerializer<List<To>> forList() => (fs) => fs.map(this).toList();
}
