import 'package:kuromoji/src/dict/dynamic_dictionaries.dart';
import 'package:kuromoji/src/token.dart';
import 'package:kuromoji/src/viterbi/viterbi_builder.dart';
import 'package:kuromoji/src/viterbi/viterbi_searcher.dart';
import 'package:kuromoji/src/viterbi/viterbi_node.dart';

class Tokenizer {
  final DynamicDictionaries dictionaries;
  final ViterbiBuilder viterbiBuilder;
  final ViterbiSearcher viterbiSearcher;

  Tokenizer(this.dictionaries)
      : viterbiBuilder = ViterbiBuilder(dictionaries),
        viterbiSearcher = ViterbiSearcher(dictionaries.connectionCosts);

  List<UnknownToken> tokenize(String text) {
    final sentences = _splitByPunctuation(text).where((s) => s.isNotEmpty);
    final tokens = <UnknownToken>[];
    for (final sentence in sentences) {
      _tokenizeForSentence(sentence, tokens);
    }
    return tokens;
  }

  void _tokenizeForSentence(String sentence, List<UnknownToken> tokens) {
    final lattice = viterbiBuilder.build(sentence);
    final bestPath = viterbiSearcher.search(lattice);
    var lastPos = 0;
    if (tokens.isNotEmpty) {
      lastPos = tokens.last.wordPosition;
    }

    for (final node in bestPath) {
      final token = _formatNode(node, lastPos);
      tokens.add(token);
    }
  }

  UnknownToken _formatNode(ViterbiNode node, int lastPos) {
    final featuresLine = dictionaries.tokenInfoDictionary.getFeatures(node.name);
    final features = featuresLine?.split(',') ?? [];
    return UnknownToken.from(node.name, lastPos + node.startPos, node.type, features, node.surfaceForm);
  }

  List<String> _splitByPunctuation(String text) {
    List<String> sentences = [];
    String tail = text;

    while (true) {
      if (tail.isEmpty) {
        break;
      }
      var index = tail.indexOf(RegExp(r'[、。]'));
      if (index < 0) {
        sentences.add(tail);
        break;
      }
      sentences.add(tail.substring(0, index + 1));
      tail = tail.substring(index + 1);
    }

    return sentences;
  }
}
