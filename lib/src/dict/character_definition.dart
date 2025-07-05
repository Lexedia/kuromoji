import 'dart:convert';
import 'dart:typed_data';
import 'package:kuromoji/src/util/byte_buffer.dart';
import 'package:kuromoji/src/dict/invoke_definition_map.dart';
import 'package:kuromoji/src/dict/character_class.dart';

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
    final parts = line.split(RegExp(r'\s+'));
    final category = parts[0];
    final invoke = int.parse(parts[1]);
    final grouping = int.parse(parts[2]);
    final maxLength = int.parse(parts[3]);
    final charClass = CharacterClass(
        classId, category, invoke == 1, grouping == 1, maxLength);
    invokeDefinitionMap.characterClasses.add(charClass);
    invokeDefinitionMap.categoryToId[category] = classId;
  }

  void _parseCategoryMapping(String line) {
    final parts = line.split(RegExp(r'\s+'));
    final range = parts[0].split('..');
    final start = int.parse(range[0]);
    final end = range.length > 1 ? int.parse(range[1]) : start;
    final defaultCategory = parts[1];
    final compatibleCategories = parts.sublist(2);

    for (var codePoint = start; codePoint <= end; codePoint++) {
      characterCategoryMap[codePoint] = invokeDefinitionMap.lookup(defaultCategory);
      for (final category in compatibleCategories) {
        final classId = invokeDefinitionMap.lookup(category);
        compatibleCategoryMap[codePoint] |= 1 << classId;
      }
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
      if ((bitset & (1 << i)) != 0) {
        final charClass = invokeDefinitionMap.getCharacterClass(i);
        if (charClass != null) {
          classes.add(charClass);
        }
      }
    }
    return classes;
  }
}
