sealed class HList {
  static NonEmptyHList<H, HNil> call<H>(H h) => NonEmptyHList(h, HNil._instance);
}

final class HNil extends HList {
  HNil._();
  static final HNil _instance = HNil._();

  factory HNil() => _instance;

  NonEmptyHList<H, HNil> prepend<H>(H head) => NonEmptyHList(head, this);
}

final class NonEmptyHList<Head, Tail extends HList> extends HList {
  final Head head;
  final Tail tail;

  NonEmptyHList(this.head, this.tail);

  NonEmptyHList<H, NonEmptyHList<Head, Tail>> prepend<H>(H h) => NonEmptyHList(h, this);
}

extension HListExtensions<H> on H {
  NonEmptyHList<H, HNil> hlist() => NonEmptyHList(this, HNil());
  NonEmptyHList<H, Tail> prependTo<Tail extends HList>(Tail tail) => NonEmptyHList(this, tail);
}

void testThings() {
  final list = 1.hlist();
  final again = "hi".prependTo(list);
}

class MultiBlocBuilder<Blocs extends HList> {
  Blocs blocs;
  Widget Function(Bu)

  MultiBlocBuilder({ required this.blocs });
}