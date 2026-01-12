import 'dart:typed_data';
import 'package:kuromoji/src/dict/data/char.dart';
import 'src/dictionary_loader.dart';
import 'src/dict/dynamic_dictionaries.dart';
import 'src/tokenizer.dart';

class TokenizerBuilder {
  TokenizerBuilder();

  Tokenizer build() {
    final loader = DictionaryLoader();
    final data = loader.load();
    final charDef = _loadCharDef();
    final dictionaries = DynamicDictionaries(data, charDef);
    return Tokenizer(dictionaries);
  }

  Uint8List _loadCharDef() {
    return charData;
  }
}
