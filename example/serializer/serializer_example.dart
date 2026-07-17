import 'dart:convert';

import 'package:zadart/zadart.dart';

/// Data classes with the common `fromJson(Map<String, dynamic>)` shape found in
/// many Dart/Flutter apps.
class User {
  final String name;
  final int age;
  const User(this.name, this.age);

  factory User.fromJson(Map<String, dynamic> json) =>
      User(json['name'] as String, json['age'] as int);

  @override
  String toString() => 'User($name, $age)';
}

class Event {
  final String title;
  final String host;
  const Event(this.title, this.host);

  factory Event.fromJson(Map<String, dynamic> json) =>
      Event(json['title'] as String, json['host'] as String);

  @override
  String toString() => 'Event($title by $host)';
}

/// Because a `fromJson` factory already *is* a
/// `Serializer<Map<String, dynamic>, T>`, one generic helper can parse a JSON
/// string into any such type — no per-type parsing boilerplate.
T parseJson<T>(Serializer<Map<String, dynamic>, T> fromJson, String source) =>
    fromJson.jsonSerializer()(jsonDecode(source));

List<T> parseJsonList<T>(
        Serializer<Map<String, dynamic>, T> fromJson, String source) =>
    fromJson.jsonListSerializer()(jsonDecode(source));

/// Examples for the [Serializer] typedef and its combinators, centered on the
/// most useful application: turning `jsonDecode` output into typed values.
void main() {
  // A `fromJson` tear-off satisfies `Serializer<Map<String, dynamic>, T>`.
  final Serializer<Map<String, dynamic>, User> userFromJson = User.fromJson;

  // The same generic helpers work across unrelated types by passing their
  // `fromJson` tear-offs.
  final user = parseJson(User.fromJson, '{"name":"Ada","age":36}');
  print(user); // User(Ada, 36)

  final events = parseJsonList(
    Event.fromJson,
    '[{"title":"Keynote","host":"Ada"},{"title":"Panel","host":"Alan"}]',
  );
  print(events.map((e) => e.title).toList()); // [Keynote, Panel]

  // Or hold onto a reusable serializer built from the same tear-off.
  final JsonSerializer<User> parseUser = userFromJson.jsonSerializer();
  print(parseUser(jsonDecode('{"name":"Grace","age":45}'))); // User(Grace, 45)

  // `contraMap` adapts the *input* side — here turning `User.fromJson` (which
  // expects a map) into a serializer that consumes a raw JSON string.
  final Serializer<String, User> userFromJsonString =
      userFromJson.contraMap((s) => jsonDecode(s) as Map<String, dynamic>);
  print(userFromJsonString('{"name":"Alan","age":41}')); // User(Alan, 41)

  // `map` adapts the *output* side — project a field out of the parsed value.
  final JsonSerializer<String> parseUserName =
      userFromJson.map((u) => u.name).jsonSerializer();
  print(parseUserName(jsonDecode('{"name":"Ada","age":36}'))); // Ada
}
