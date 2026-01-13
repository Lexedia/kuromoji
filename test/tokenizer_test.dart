import 'package:kuromoji/kuromoji.dart';
import 'package:test/test.dart';

void main() {
  late Tokenizer tokeniser;

  setUp(() {
    tokeniser = Tokenizer.buildSync();
  });

  group('splitByPunctuation', () {
    test('no punctuation', () {
      final result = tokeniser.test$$_splitByPunctuation('すもももももももものうち');
      expect(result, ['すもももももももものうち']);
    });

    test('with single punctuation', () {
      final result = tokeniser.test$$_splitByPunctuation('、');
      expect(result, ['、']);
    });

    test('with single punctuation - 2', () {
      final result = tokeniser.test$$_splitByPunctuation('。');
      expect(result, ['。']);
    });

    test('mutliple punctuations', () {
      final result = tokeniser.test$$_splitByPunctuation('すもも、も、もも。もも、も、もも。');
      expect(result, ['すもも、', 'も、', 'もも。', 'もも、', 'も、', 'もも。']);
    });

    test('with mixed punctuation', () {
      final result = tokeniser.test$$_splitByPunctuation('、𠮷野屋。漢字。');
      expect(result, ['、', '𠮷野屋。', '漢字。']);
    });
  });

  group('tokenise', () {
    test('simple tokenisation', () {
      var tokens = tokeniser.tokenize("すもももももももものうち");
      expect(tokens.map((t) => t.surfaceForm).toList(), ['すもも', 'も', 'もも', 'も', 'もも', 'の', 'うち']);
      expect(tokens.length, equals(4));
      expect(tokens.whereType<Token>().length, equals(4));
      expect(tokens[1].reading, equals('モ'));
    });

    test('tokenisation with unknown words', () {
      var tokens = tokeniser.tokenize("となりのトトロ");
      expect(tokens.map((t) => t.surfaceForm).toList(), ['となり', 'の', 'トトロ']);
      expect(tokens.length, equals(3));
      expect(tokens.whereType<Token>().length, equals(1));
      expect(tokens[2].reading, equals('クサゥ'));
    });

    test('blank input', () {
      var tokens = tokeniser.tokenize("");
      expect(tokens.length, equals(0));
    });

    test('sentence include UTF-16 surrogate pair', () {
      var tokens = tokeniser.tokenize("𠮷野屋");
      expect(tokens.length, equals(3));
      expect(tokens[0].wordPosition, equals(1));
      expect(tokens[1].wordPosition, equals(2));
      expect(tokens[2].wordPosition, equals(3));
    });

    test("Sentence include punctuation あ、あ。あ、あ。 returns correct positions", () {
      var path = tokeniser.tokenize("あ、あ。あ、あ。");
      expect(path.length, equals(8));
      expect(path[0].wordPosition, equals(1));
      expect(path[1].wordPosition, equals(2));
      expect(path[2].wordPosition, equals(3));
      expect(path[3].wordPosition, equals(4));
      expect(path[4].wordPosition, equals(5));
      expect(path[5].wordPosition, equals(6));
      expect(path[6].wordPosition, equals(7));
      expect(path[7].wordPosition, equals(8));
    });
  });
}
