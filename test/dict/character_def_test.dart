import 'dart:io';

import 'package:kuromoji/src/dict/character_class.dart';
import 'package:kuromoji/src/dict/character_definition.dart';
import 'package:kuromoji/src/util/byte_buffer.dart';
import 'package:test/test.dart';

void main() {
  late CharacterDefinition characterDefinition;

  setUp(() async {
    final data = await File('dict/char.def').readAsBytes();

    characterDefinition = CharacterDefinition(ByteBuffer(data));
  });

  CharacterClass lu(String char) => characterDefinition.lookup(char)!;
  List<CharacterClass> lucc(String char) => characterDefinition.lookupCompatibleCategory(char);

  group('CharacterDefinition', () {
    test('lookup by space, return SPACE', () {
      expect(lu(' ').category, equals('SPACE'));
    });

    test('lookup by 日 return KANJI', () {
      expect(lu('日').category, equals('KANJI'));
    });

    test('lookup by ! return SYMBOL', () {
      expect(lu('!').category, equals('SYMBOL'));
    });

    test('lookup by 1, return NUMERIC', () {
      expect(lu('1').category, equals('NUMERIC'));
    });

    test('lookup by A, return ALPHA', () {
      expect(lu('A').category, equals('ALPHA'));
    });

    test('lookup by あ, return HIRAGANA', () {
      expect(lu('あ').category, equals('HIRAGANA'));
    });

    test('lookup by ア, return KATAKANA', () {
      expect(lu('ア').category, equals('KATAKANA'));
    });

    test('lookup by 一, return KANJNUMERIC', () {
      expect(lu('一').category, equals('KANJINUMERIC'));
    });

    test('lookup by surrogate pair character, return DEFAULT', () {
      expect(lu('𠮷').category, equals('DEFAULT'));
    });

    test('lookup by 一, return KANJI as a compatible category', () {
      expect(lucc('一').first.category, equals('KANJI'));
    });

    test('lookup by 〇, return KANJINUMERIC as a compatible category', () {
      expect(lucc(String.fromCharCode(0x3007)).first.category, equals('KANJINUMERIC'));
    });
  });
}
