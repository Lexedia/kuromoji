import 'dart:typed_data';

class ByteBuffer {
  final Uint8List buffer;
  int position = 0;

  ByteBuffer(this.buffer);

  int getInt(int offset) {
    return buffer.buffer.asByteData().getInt32(offset, Endian.little);
  }

  void putInt(int offset, int value) {
    buffer.buffer.asByteData().setInt32(offset, value, Endian.little);
  }

  int readInt32() {
    final value = getInt(position);
    position += 4;
    return value;
  }

  int readInt16() {
    final value = buffer.buffer.asByteData().getInt16(position, Endian.little);
    position += 2;
    return value;
  }

  String readString(int length) {
    final bytes = buffer.sublist(position, position + length);
    position += length;
    return String.fromCharCodes(bytes);
  }

  Uint8List readBytesFrom(int offset) {
    final start = offset;
    var end = start;
    while (end < buffer.length && buffer[end] != 0) {
      end++;
    }
    return buffer.sublist(start, end);
  }
}
