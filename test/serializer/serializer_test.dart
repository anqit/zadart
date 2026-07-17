import 'dart:convert';

import 'package:test/test.dart';
import 'package:zadart/zadart.dart';

typedef User = ({String name, int age});

User _userFromMap(Map<String, dynamic> m) =>
    (name: m['name'] as String, age: m['age'] as int);

void main() {
  final Serializer<Map<String, dynamic>, User> fromMap = _userFromMap;

  group('map', () {
    test('post-processes the output', () {
      final name = fromMap.map((u) => u.name);
      expect(name({'name': 'Ada', 'age': 36}), 'Ada');
    });
  });

  group('contraMap', () {
    test('adapts the input type', () {
      // Turn a Map-based serializer into one that consumes a raw JSON string.
      final Serializer<String, User> fromJsonString =
          fromMap.contraMap((String s) => jsonDecode(s) as Map<String, dynamic>);
      expect(fromJsonString('{"name":"Ada","age":36}'), (name: 'Ada', age: 36));
    });
  });

  group('forList', () {
    test('lifts a serializer over a list of inputs', () {
      final many = fromMap.forList();
      final users = many([
        {'name': 'Ada', 'age': 36},
        {'name': 'Alan', 'age': 41},
      ]);
      expect(users.map((u) => u.name), ['Ada', 'Alan']);
    });
  });

  group('jsonSerializer', () {
    test('parses the dynamic result of jsonDecode', () {
      final parse = fromMap.jsonSerializer();
      final user = parse(jsonDecode('{"name":"Ada","age":36}'));
      expect(user, (name: 'Ada', age: 36));
    });
  });

  group('jsonListSerializer', () {
    test('parses a decoded JSON array', () {
      final parse = fromMap.jsonListSerializer();
      final users =
          parse(jsonDecode('[{"name":"Ada","age":36},{"name":"Al","age":9}]'));
      expect(users.map((u) => u.name), ['Ada', 'Al']);
    });
  });

  group('jsonBoolSerializer', () {
    test('decodes a JSON boolean from its string form', () {
      expect(jsonBoolSerializer('true'), isTrue);
      expect(jsonBoolSerializer('false'), isFalse);
    });
  });
}
