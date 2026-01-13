## 2.0.0-dev.1
- `TokenizerBuilder` has been removed, use `Tokenizer.buildSync` directly.
- `Tokenizer.tokenize` now returns a `List<UnknownToken>` instead of `List<Map<String, Object?>>`. To have the old behaviour, you can call `toJson` on the token instance.
- Fixed an issue with surrogate pairs not being handled correctly.
- This also fixed an issue when parsing the character definitions file, which would cause the tokenizer to not work correctly in some cases.

## 1.0.5
- This adds web support and moves to a base64 embedding for the dictionaries.
Thanks to [Bruno D'Luka](https://github.com/bdlukaa) for his PR.

## 1.0.4
- This reverts the change made in 1.0.3 to remove embedded dicts, AoT compilation would fail.

## 1.0.3
- Removed embedded dicts.

## 1.0.2
- Fixed a condition that'd add more tokens than necessary

## 1.0.1
- Lowered the minimum sdk constraint.

## 1.0.0

- Initial version.
