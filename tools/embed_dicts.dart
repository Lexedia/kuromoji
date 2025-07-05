import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

void main(List<String> args) async {
  final dictDir = Directory('dict');
  final e = await dictDir.list().where((e) => e is File).cast<File>().toList();

  for (final f in e) {
    final contents = await f.readAsBytes();
    await File(
      'lib/src/dict/data/${path.basenameWithoutExtension(f.path)}.dart',
    ).writeAsString('''
import 'dart:typed_data';

final ${path.basenameWithoutExtension(f.path).replaceAll('.dat', '').replaceAll('.def', '')}Data = Uint16List.fromList(_embeddedData.codeUnits).buffer.asUint8List();

const _embeddedData = '${bytesAsString(contents)}';
''');
  }
}

String bytesAsString(Uint8List bytes) {
  assert(bytes.length.isEven);
  return bytes.buffer
      .asUint16List()
      .map((u) => '\\u${u.toRadixString(16).padLeft(4, '0')}')
      .join();
}
