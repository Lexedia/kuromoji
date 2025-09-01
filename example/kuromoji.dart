import 'dart:convert';

import 'package:kuromoji/kuromoji.dart';

void main() async {
  final tokenizer = await TokenizerBuilder().build();

  final tokens = tokenizer.tokenize('リミッター働くまで');
  print(JsonEncoder.withIndent(' ' * 2).convert(tokens)); // →
  /**
   *[
   *  {
   *    "word_id": 230,
   *    "word_position": 1,
   *    "word_type": "UNKNOWN",
   *    "surface_form": "リミッター",
   *    "pos": "名詞",
   *    "pos_detail_1": "一般",
   *    "pos_detail_2": "*",
   *    "pos_detail_3": "*",
   *    "conjugated_type": "*",
   *    "conjugated_form": "*",
   *    "basic_form": "*",
   *    "reading": null,
   *    "pronunciation": null
   *  },
   *  {
   *    "word_id": 2615990,
   *    "word_position": 6,
   *    "word_type": "KNOWN",
   *    "surface_form": "働く",
   *    "pos": "動詞",
   *    "pos_detail_1": "自立",
   *    "pos_detail_2": "*",
   *    "pos_detail_3": "*",
   *    "conjugated_type": "五段・カ行イ音便",
   *    "conjugated_form": "基本形",
   *    "basic_form": "働く",
   *    "reading": "ハタラク",
   *    "pronunciation": "ハタラク"
   *  },
   *  {
   *    "word_id": 93130,
   *    "word_position": 8,
   *    "word_type": "KNOWN",
   *    "surface_form": "まで",
   *    "pos": "助詞",
   *    "pos_detail_1": "副助詞",
   *    "pos_detail_2": "*",
   *    "pos_detail_3": "*",
   *    "conjugated_type": "*",
   *    "conjugated_form": "*",
   *    "basic_form": "まで",
   *    "reading": "マデ",
   *    "pronunciation": "マデ"
   *  }
   *]
   */
}
