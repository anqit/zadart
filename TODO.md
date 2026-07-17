# TODO / Roadmap

Deferred items from the pre-0.1.0 library review. None are blockers for 0.1.0;
they're candidates for future versions.

## Trie (highest priority — most incomplete)
- Prefix search: `keysWithPrefix`, `longestPrefixOf` — the primary reason to use
  a trie over a nested map.
- Node removal (`remove` / delete).
- Consider a post-order *linear* fold to complement `foldUp` (the catamorphism),
  mirroring `foldDown`. See discussion: up-folds merge multiple children, so the
  linear form would be a separate method, not a replacement.

## Functions
- Larger-arity `noop` variants (`noop2`, `noop3`, …) if a need arises.

## Collections
- Revisit `mergeMap` / `mergeMapWithKey` / `mergeMapWithDefaults` ergonomics — the
  positional multi-callback signatures are hard to read at call sites (named params?).
- `deepEquals`/`deepUnequal` (and the `DeepCollectionEquality.unequal` extension)
  duplicate each other; kept for readability, but could be trimmed.

## Strings
- The `strings` module is currently a single-method stub (`isDigit`). Expand
  (`isBlank`, `capitalize`, `truncate`, …) or fold elsewhere.
