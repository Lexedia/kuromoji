import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> args) async {
  final dictDir = Directory('dict');
  if (!await dictDir.exists()) {
    print('Error: "dict" directory not found.');
    return;
  }

  final files = await dictDir.list().where((e) => e is File).cast<File>().toList();

  for (final f in files) {
    final fileName = path.basenameWithoutExtension(f.path);
    print('Processing $fileName...');

    final contents = await f.readAsBytes();
    final variableName = fileName.replaceAll('.dat', '').replaceAll('.def', '') + 'Data';

    // Use base64 encoding to support all file lengths safely
    final encoded = base64Encode(contents);

    await File(
      'lib/src/dict/data/$fileName.dart',
    ).writeAsString('''
import 'dart:convert';
import 'dart:typed_data';

final Uint8List $variableName = base64Decode(_embeddedData);

const _embeddedData = '$encoded';
''');
  }
  print('Done embedding dictionaries.');
}
