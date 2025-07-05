import 'dart:typed_data';
import 'package:kuromoji/src/dict/dynamic_dictionaries.dart';
import 'package:kuromoji/src/viterbi/viterbi_lattice.dart';
import 'package:kuromoji/src/viterbi/viterbi_node.dart';

class ViterbiBuilder {
  final DynamicDictionaries dictionaries;

  ViterbiBuilder(this.dictionaries);

  ViterbiLattice build(String text) {
    final lattice = ViterbiLattice.create();
    final bd = dictionaries.tokenInfoDictionary.buffer.buffer.buffer
        .asByteData();
    final ubd = dictionaries.unknownDictionary.buffer.buffer.buffer
        .asByteData();

    String key;
    for (var pos = 0; pos < text.length; pos++) {
      final tail = text.substring(pos);
      final vocabulary = dictionaries.trie.commonPrefixSearch(tail).toList();

      for (final entry in vocabulary) {
        final trieId = entry['v'] as int;
        key = entry['k'] as String;

        final tokenInfoIds =
            dictionaries.tokenInfoDictionary.targetMap[trieId] ?? [];
        for (final tokenId in tokenInfoIds) {
          final leftId = bd.getInt16(tokenId, Endian.little);
          final rightId = bd.getInt16(tokenId + 2, Endian.little);
          final wordCost = bd.getInt16(tokenId + 4, Endian.little);

          lattice.append(
            ViterbiNode(
              name: tokenId,
              cost: wordCost,
              startPos: pos + 1,
              length: key.length,
              type: 'KNOWN',
              leftId: leftId,
              rightId: rightId,
              surfaceForm: key,
            ),
          );
        }
      }

      final char = tail.substring(0, 1);
      final charClass = dictionaries.characterDefinition.lookup(char);
      if (charClass != null ||
          vocabulary.isEmpty ||
          charClass?.isInvoke == true) {
        key = char;
        if (charClass?.isGrouping == true && tail.length > 1) {
          for (var k = 1; k < tail.length; k++) {
            var rune = tail.runes.elementAt(k);
            final nextChar = String.fromCharCode(rune);
            final nextCharClass = dictionaries.characterDefinition.lookup(nextChar);
            if (charClass?.category != (nextCharClass?.category ?? '')) {
              break;
            }
            key += nextChar;
          }
        }
        final unkIds =
            dictionaries.unknownDictionary.targetMap[charClass!.classId] ?? [];
        for (final unkId in unkIds) {
          final leftId = ubd.getInt16(unkId, Endian.little);
          final rightId = ubd.getInt16(unkId + 2, Endian.little);
          final wordCost = ubd.getInt16(unkId + 4, Endian.little);

          lattice.append(
            ViterbiNode(
              name: unkId,
              cost: wordCost,
              startPos: pos + 1,
              length: key.length,
              type: 'UNKNOWN',
              leftId: leftId,
              rightId: rightId,
              surfaceForm: key,
            ),
          );
        }
      }
      continue;
    }

    lattice.appendEos();
    return lattice;
  }
}
