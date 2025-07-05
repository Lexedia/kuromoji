import 'package:kuromoji/src/dict/dynamic_dictionaries.dart';
import 'package:kuromoji/src/viterbi/viterbi_builder.dart';
import 'package:kuromoji/src/viterbi/viterbi_searcher.dart';
import 'package:kuromoji/src/util/ipadict_formatter.dart';
import 'package:kuromoji/src/viterbi/viterbi_node.dart';

class Tokenizer {
  final DynamicDictionaries dictionaries;
  final ViterbiBuilder viterbiBuilder;
  final ViterbiSearcher viterbiSearcher;
  final IpadicFormatter formatter;

  Tokenizer(this.dictionaries)
      : viterbiBuilder = ViterbiBuilder(dictionaries),
        viterbiSearcher = ViterbiSearcher(dictionaries.connectionCosts),
        formatter = IpadicFormatter();

  List<Map<String, dynamic>> tokenize(String text) {
    final sentences = _splitByPunctuation(text);
    final tokens = <Map<String, dynamic>>[];
    for (final sentence in sentences) {
      _tokenizeForSentence(sentence, tokens);
    }
    return tokens;
  }

  void _tokenizeForSentence(String sentence, List<Map<String, dynamic>> tokens) {
    final lattice = viterbiBuilder.build(sentence);
    final bestPath = viterbiSearcher.search(lattice);
    var lastPos = 0;
    if (tokens.isNotEmpty) {
      lastPos = tokens.last['word_position'] as int;
    }

    for (final node in bestPath) {
      final token = _formatNode(node, lastPos);
      tokens.add(token);
    }
  }

  Map<String, dynamic> _formatNode(ViterbiNode node, int lastPos) {
    if (node.type == 'KNOWN') {
      final featuresLine = dictionaries.tokenInfoDictionary.getFeatures(node.name);
      final features = featuresLine?.split(',') ?? [];
      return formatter.formatEntry(
          node.name, lastPos + node.startPos, node.type, features);
    } else if (node.type == 'UNKNOWN') {
      final featuresLine = dictionaries.unknownDictionary.getFeatures(node.name);
      final features = featuresLine?.split(',') ?? [];
      return formatter.formatUnknownEntry(node.name,
          lastPos + node.startPos, node.type, features, node.surfaceForm!);
    } else {
      return formatter.formatEntry(
        node.name, lastPos + node.startPos, node.type, []);
    }
  }

  List<String> _splitByPunctuation(String text) {
    return text.split(RegExp(r'[、。]'));
  }
}
