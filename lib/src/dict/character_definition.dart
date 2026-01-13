import 'dart:convert';
import 'dart:typed_data';
import 'package:kuromoji/src/util/byte_buffer.dart';
import 'package:kuromoji/src/dict/invoke_definition_map.dart';
import 'package:kuromoji/src/dict/character_class.dart';

const hexpattern = '(0x[0-9A-F]{4})';

class CharacterDefinition {
  final Uint8List characterCategoryMap = Uint8List(65536);
  final Uint32List compatibleCategoryMap = Uint32List(65536);
  final InvokeDefinitionMap invokeDefinitionMap = InvokeDefinitionMap();

  CharacterDefinition(ByteBuffer buffer) {
    final lines = utf8.decode(buffer.buffer).split('\n');
    var classId = 0;
    for (final line in lines) {
      if (line.startsWith('#') || line.trim().isEmpty) {
        continue;
      }

      if (line.startsWith('0x')) {
        _parseCategoryMapping(line);
      } else {
        _parseCharCategory(classId++, line);
      }
    }
  }

  void _parseCharCategory(int classId, String line) {
    final parts = RegExp(r'^(\w+)\s+(\d)\s+(\d)\s+(\d)').firstMatch(line)!;
    final category = parts[1]!;
    final invoke = parts[2]!;
    final grouping = parts[3]!;
    final maxLength = int.parse(parts[4]!);
    final charClass = CharacterClass(classId, category, invoke == '1', grouping == '1', maxLength);
    invokeDefinitionMap.characterClasses.add(charClass);
    invokeDefinitionMap.categoryToId[category] = classId;
  }

  void _parseCategoryMapping(String line) {
    bool isRange = line.contains('..');
    final m = RegExp('^${isRange ? '$hexpattern\\.\\.$hexpattern' : hexpattern}(?:\\s+([^#\\s]+))(?:\\s+([^#\\s]+))*')
        .firstMatch(line)!;

    final start = int.parse(m[1]!);
    final end = isRange ? int.parse(m[2]!) : start;
    final defaultCategory = m[isRange ? 3 : 2]!;
    final compatibleCategories = [for (int i = (isRange ? 4 : 3); i <= m.groupCount; i++) m[i]].nonNulls;

    for (var codePoint = start; codePoint <= end; codePoint++) {
      characterCategoryMap[codePoint] = invokeDefinitionMap.lookup(defaultCategory);
      var curr = compatibleCategoryMap[codePoint];
      for (final category in compatibleCategories) {
        final classId = invokeDefinitionMap.lookup(category);
        curr |= (1 << classId);
      }
      compatibleCategoryMap[codePoint] = curr;
    }
  }

  CharacterClass? lookup(String char) {
    final code = char.codeUnitAt(0);
    if (code >= characterCategoryMap.length) {
      return null;
    }
    final classId = characterCategoryMap[code];
    return invokeDefinitionMap.getCharacterClass(classId);
  }

  List<CharacterClass> lookupCompatibleCategory(String char) {
    final code = char.codeUnitAt(0);
    if (code >= compatibleCategoryMap.length) {
      return [];
    }
    final bitset = compatibleCategoryMap[code];
    final classes = <CharacterClass>[];
    for (var i = 0; i < 32; i++) {
      if (((bitset << (31 - i)) >>> 31) == 1) {
        final charClass = invokeDefinitionMap.getCharacterClass(i);
        if (charClass != null) {
          classes.add(charClass);
        }
      }
    }
    return classes;
  }
}
