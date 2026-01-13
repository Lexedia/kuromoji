import 'dart:convert';

import 'package:kuromoji/kuromoji.dart';

void main() async {
  final tokenizer = Tokenizer.buildSync();

  final tokens = tokenizer.tokenize('リミッター働くまで');
  print(JsonEncoder.withIndent(' ' * 2).convert(tokens));
}
