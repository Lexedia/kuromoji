import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:kuromoji/src/dict/data/base.dat.dart';
import 'package:kuromoji/src/dict/data/cc.dat.dart';
import 'package:kuromoji/src/dict/data/check.dat.dart';
import 'package:kuromoji/src/dict/data/tid.dat.dart';
import 'package:kuromoji/src/dict/data/tid_map.dat.dart';
import 'package:kuromoji/src/dict/data/tid_pos.dat.dart';
import 'package:kuromoji/src/dict/data/unk.dat.dart';
import 'package:kuromoji/src/dict/data/unk_char.dat.dart';
import 'package:kuromoji/src/dict/data/unk_compat.dat.dart';
import 'package:kuromoji/src/dict/data/unk_invoke.dat.dart';
import 'package:kuromoji/src/dict/data/unk_map.dat.dart';
import 'package:kuromoji/src/dict/data/unk_pos.dat.dart';

class DictionaryLoader {
  DictionaryLoader();

  Map<String, Uint8List> load() {
    final decoder = GZipDecoder();

    return {
      'base.dat': decoder.decodeBytes(baseData),
      'cc.dat': decoder.decodeBytes(ccData),
      'check.dat': decoder.decodeBytes(checkData),
      'tid_map.dat': decoder.decodeBytes(tid_mapData),
      'tid_pos.dat': decoder.decodeBytes(tid_posData),
      'tid.dat': decoder.decodeBytes(tidData),
      'unk_char.dat': decoder.decodeBytes(unk_charData),
      'unk_compat.dat': decoder.decodeBytes(unk_compatData),
      'unk_invoke.dat': decoder.decodeBytes(unk_invokeData),
      'unk_map.dat': decoder.decodeBytes(unk_mapData),
      'unk_pos.dat': decoder.decodeBytes(unk_posData),
      'unk.dat': decoder.decodeBytes(unkData),
    };
  }
}
