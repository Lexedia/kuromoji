# Kuromoji

A re-implementation of [kuromoji.js](https://github.com/takuyaa/kuromoji.js) in Dart.

## Usage

```dart
import 'package:kuromoji/kuromoji.dart';
void main() async {
  final tokenizer = await TokenizerBuilder().build();
  final tokens = tokenizer.tokenize('すもももももももものうち');
  for (final token in tokens) {
    print(token);
  }
}
```
