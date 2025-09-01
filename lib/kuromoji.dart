import 'dart:typed_data';
import 'package:kuromoji/src/dict/data/char.dart';
import 'src/dictionary_loader.dart';
import 'src/dict/dynamic_dictionaries.dart';
import 'src/tokenizer.dart';

class TokenizerBuilder {
  TokenizerBuilder();

  Future<Tokenizer> build() async {
    final loader = DictionaryLoader();
    final data = await loader.load();
    final charDef = await _loadCharDef();
    final dictionaries = DynamicDictionaries(data, charDef);
    return Tokenizer(dictionaries);
  }

  Future<Uint8List> _loadCharDef() async {
    return charData;
  }
}
