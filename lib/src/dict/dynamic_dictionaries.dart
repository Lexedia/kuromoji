import 'dart:typed_data';
import 'package:kuromoji/src/util/byte_buffer.dart';
import 'package:kuromoji/src/dict/token_info_dictionary.dart';
import 'package:kuromoji/src/dict/unknown_dictionary.dart';
import 'package:kuromoji/src/dict/connection_costs.dart';
import 'package:kuromoji/src/dict/double_array_trie.dart';
import 'package:kuromoji/src/dict/character_definition.dart';

class DynamicDictionaries {
  late TokenInfoDictionary tokenInfoDictionary;
  late UnknownDictionary unknownDictionary;
  late ConnectionCosts connectionCosts;
  late CharacterDefinition characterDefinition;
  late DoubleArray trie;

  DynamicDictionaries(Map<String, Uint8List> data, Uint8List charDef) {
    tokenInfoDictionary = TokenInfoDictionary(
      ByteBuffer(data['tid.dat']!),
      ByteBuffer(data['tid_pos.dat']!),
      ByteBuffer(data['tid_map.dat']!),
    );
    unknownDictionary = UnknownDictionary(
      ByteBuffer(data['unk.dat']!),
      ByteBuffer(data['unk_pos.dat']!),
      ByteBuffer(data['unk_map.dat']!),
      ByteBuffer(data['unk_char.dat']!),
      ByteBuffer(data['unk_compat.dat']!),
      ByteBuffer(data['unk_invoke.dat']!),
    );
    connectionCosts = ConnectionCosts(ByteBuffer(data['cc.dat']!));
    characterDefinition = CharacterDefinition(ByteBuffer(charDef));
    trie = DoubleArrayTrie.load(
      Int32List.view(data['base.dat']!.buffer),
      Int32List.view(data['check.dat']!.buffer),
    );
  }
}
