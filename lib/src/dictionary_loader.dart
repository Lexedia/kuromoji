import 'dart:io';
import 'dart:typed_data';

import 'package:kuromoji/src/util/util.dart';

class DictionaryLoader {
  late final Directory dictDir;

  DictionaryLoader();

  Future<Map<String, Uint8List>> load() async {
    dictDir = await getDictDir();
    final files = {
      'base.dat',
      'cc.dat',
      'check.dat',
      'tid_map.dat',
      'tid_pos.dat',
      'tid.dat',
      'unk_char.dat',
      'unk_compat.dat',
      'unk_invoke.dat',
      'unk_map.dat',
      'unk_pos.dat',
      'unk.dat',
    };

    Map<String, Uint8List> out = {};

    for (final file in files) {
      out[file] = Uint8List.fromList(gzip.decode(await File('${dictDir.path}/$file.gz').readAsBytes()));
    }

    return out;
  }

  Future<Uint8List> loadCharDef() {
    return File('${dictDir.path}/char.def').readAsBytes();
  }
}
