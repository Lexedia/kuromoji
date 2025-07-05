import 'dart:convert';

import 'package:kuromoji/src/util/byte_buffer.dart';

class UnknownDictionary {
  final ByteBuffer buffer;
  final ByteBuffer posBuffer;
  final ByteBuffer mapBuffer;
  final ByteBuffer charBuffer;
  final ByteBuffer compatBuffer;
  final ByteBuffer invokeBuffer;
  final Map<int, List<int>> targetMap = {};

  UnknownDictionary(
    this.buffer,
    this.posBuffer,
    this.mapBuffer,
    this.charBuffer,
    this.compatBuffer,
    this.invokeBuffer,
  ) {
    _loadTargetMap();
  }

  void _loadTargetMap() {
    var p = 0;
    final size = mapBuffer.getInt(p);
    p += 4;
    for (var i = 0; i < size; i++) {
      final key = mapBuffer.getInt(p);
      p += 4;
      final valuesSize = mapBuffer.getInt(p);
      p += 4;
      final values = <int>[];
      for (var j = 0; j < valuesSize; j++) {
        values.add(mapBuffer.getInt(p));
        p += 4;
      }
      targetMap[key] = values;
    }
  }

  String? getFeatures(int tokenId) {
    final posId = buffer.getInt(tokenId + 6);
    final bytes = posBuffer.readBytesFrom(posId);
    return utf8.decode(bytes);
  }
}
