import 'src/dictionary_loader.dart';
import 'src/dict/dynamic_dictionaries.dart';
import 'src/tokenizer.dart';

class TokenizerBuilder {
  TokenizerBuilder();

  Future<Tokenizer> build() async {
    final loader = DictionaryLoader();
    final data = await loader.load();
    final charDef = await loader.loadCharDef();
    final dictionaries = DynamicDictionaries(data, charDef);
    return Tokenizer(dictionaries);
  }
}
