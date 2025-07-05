import 'package:kuromoji/src/dict/character_class.dart';

class InvokeDefinitionMap {
  final Map<String, int> categoryToId = {};
  final List<CharacterClass> characterClasses = [];

  int lookup(String category) {
    return categoryToId[category] ?? 0;
  }

  CharacterClass? getCharacterClass(int classId) {
    if (classId < 0 || classId >= characterClasses.length) {
      return null;
    }
    return characterClasses[classId];
  }
}
