import 'dart:typed_data';
import 'package:kuromoji/src/util/byte_buffer.dart';

class ConnectionCosts {
  final ByteBuffer buffer;
  late final int forwardDimension;
  late final int backwardDimension;

  ConnectionCosts(this.buffer) {
    forwardDimension = buffer.readInt16();
    backwardDimension = buffer.readInt16();
  }

  int get(int forwardId, int backwardId) {
    final index = forwardId * backwardDimension + backwardId;
    return buffer.buffer.buffer.asByteData().getInt16(4 + index * 2, Endian.little);
  }
}
