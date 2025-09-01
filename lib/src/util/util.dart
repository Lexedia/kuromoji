import 'dart:io';

Future<Directory> getDictDir() async {
  final pubCache = Platform.environment['PUB_CACHE'] ??
      (Platform.isWindows
          ? '${Platform.environment['APPDATA']}\\Pub\\Cache'
          : '${Platform.environment['HOME']}/.pub-cache');

  // pub has multiple ways to store packages, from git, path or hosted.
  // hosted dependencies are generally stored in $PUB_CACHE/hosted/pub.dev/{name}-{version}
  // git dependencies are stored in $PUB_CACHE/git/{name}-{hash}
  // and path dependencies are not stored in pub cache. Supporting path dependencies is out of scope for now. So we only check hosted and git.
  // our package needs to read the folder `dict` which is located in the root of the package. So we need to find the root of the package first.

  // We first check hosted packages.
  final hostedDirs = await Directory('$pubCache/hosted/pub.dev')
      .list()
      .toList()
      .then((d) => d.whereType<Directory>());
  final filtered =
      hostedDirs.where((d) => d.path.contains('kuromoji-')).toList();

  final versions = filtered.map((f) {
    final seg = f.path.split(Platform.isWindows ? r'\' : '/').last;
    final [..., v] = seg.split('-');

    var [major, minor, patch] = v.split('.');

    if (patch.contains('-')) {
      patch = patch.split('-').first;
    }

    return (int.parse(major), int.parse(minor), int.parse(patch));
  }).toList();

  versions.sort((a, b) {
    if (a.$1 != b.$1) {
      return b.$1.compareTo(a.$1);
    } else if (a.$2 != b.$2) {
      return b.$2.compareTo(a.$2);
    } else {
      return b.$3.compareTo(a.$3);
    }
  });

  final latestVersion = versions.first;

  final latestVersionStr =
      '${latestVersion.$1}.${latestVersion.$2}.${latestVersion.$3}';

  var latestDir =
      filtered.firstWhere((d) => d.path.contains('kuromoji-$latestVersionStr'));

  if (!Directory('${latestDir.path}/dict').existsSync()) {
    // Check for git packages if dict folder not found in hosted packages

    final gitDirs = await Directory('$pubCache/git')
        .list()
        .toList()
        .then((d) => d.whereType<Directory>());

    final gitFiltered =
        gitDirs.where((d) => d.path.contains('kuromoji-')).toList();

    if (gitFiltered.isEmpty) {
      return Directory('dict');
    }

    // Now the tricky part is that git directories are named with a hash, so we can't determine the version directly.
    // The "best way" would be to read the pubspec.yaml file in each directory to find the version.

    final gitVersions =
        <(Directory dir, int major, int minor, int patch, String hash)>[];

    for (var dir in gitFiltered) {
      final pubspecFile = File('${dir.path}/pubspec.yaml');
      if (pubspecFile.existsSync()) {
        final content = await pubspecFile.readAsString();
        final versionMatch =
            RegExp(r'version:\s*(\d+)\.(\d+)\.(\d+)').firstMatch(content);
        if (versionMatch != null) {
          final major = int.parse(versionMatch.group(1)!);
          final minor = int.parse(versionMatch.group(2)!);
          final patch = int.parse(versionMatch.group(3)!);

          final hashP = await Process.run(
            'git',
            ['rev-parse', 'HEAD'],
            workingDirectory: dir.path,
          );

          if (hashP.exitCode == 0) {
            final hash = (hashP.stdout as String).trim();
            gitVersions.add((dir, major, minor, patch, hash));
          }
        }
      }

      gitVersions.sort((a, b) {
        if (a.$2 != b.$2) {
          return b.$2.compareTo(a.$2);
        } else if (a.$3 != b.$3) {
          return b.$3.compareTo(a.$3);
        } else {
          return b.$4.compareTo(a.$4);
        }
      });

      final latestGitVersion = gitVersions.first;

      latestDir = latestGitVersion.$1;
    }
  }

  return (latestDir = Directory('${latestDir.path}/dict')).existsSync() ? latestDir : Directory('dict');
}
