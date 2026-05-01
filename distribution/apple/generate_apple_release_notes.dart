// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';
import 'dart:io';

const List<String> _requiredSourceLocales = <String>[
  'ar-SA',
  'ca-ES',
  'de-DE',
  'el-GR',
  'en-GB',
  'es-ES',
  'eu-ES',
  'fr-FR',
  'gl-ES',
  'hi-IN',
  'it-IT',
  'ja-JP',
  'ka-GE',
  'ko-KR',
  'pt-BR',
  'ru-RU',
  'uk-UA',
  'zh-CN',
];

const Map<String, String> _appleLocaleFallbacks = <String, String>{
  'ar-SA': 'ar-SA',
  'ca': 'ca-ES',
  'de-DE': 'de-DE',
  'el': 'el-GR',
  'en-GB': 'en-GB',
  'en-US': 'en-GB',
  'es-ES': 'es-ES',
  'fr-FR': 'fr-FR',
  'hi': 'hi-IN',
  'it': 'it-IT',
  'ja': 'ja-JP',
  'ko': 'ko-KR',
  'pt-BR': 'pt-BR',
  'ru': 'ru-RU',
  'uk': 'uk-UA',
  'zh-Hans': 'zh-CN',
};

const List<String> _targetAppleLocales = <String>[
  'ar-SA',
  'ca',
  'de-DE',
  'el',
  'en-GB',
  'en-US',
  'es-ES',
  'fr-FR',
  'hi',
  'it',
  'ja',
  'ko',
  'pt-BR',
  'ru',
  'uk',
  'zh-Hans',
];

void main(List<String> args) {
  final Map<String, String> options = _parseArgs(args);

  final File notesFile = File(
    options['input'] ?? 'distribution/release_notes.json',
  );
  if (!notesFile.existsSync()) {
    _fail('Release notes file not found: ${notesFile.path}');
  }

  final String version = _resolveVersion(options['version']);
  final Directory outputDir = Directory(
    options['output'] ?? 'fastlane/metadata',
  );

  final Map<String, dynamic> config = _readConfig(notesFile);
  final Object? rawNotes = config[version];
  if (rawNotes is! Map<String, dynamic>) {
    _fail(
      'No release notes found for version "$version" in ${notesFile.path}.',
    );
  }

  _validateSourceNotes(version: version, notes: rawNotes);

  outputDir.createSync(recursive: true);
  _clearGeneratedLocaleDirs(outputDir);

  final Set<String> unsupportedSourceLocales = <String>{
    ..._requiredSourceLocales,
  }.difference(rawNotes.keys.toSet());
  if (unsupportedSourceLocales.isNotEmpty) {
    _fail(
      'Missing required source locales for version $version: ${unsupportedSourceLocales.toList()..sort()}',
    );
  }

  for (final String appleLocale in _targetAppleLocales) {
    final String sourceLocale = _appleLocaleFallbacks[appleLocale]!;
    final String note = (rawNotes[sourceLocale] as String).trim();
    final Directory localeDir = Directory('${outputDir.path}/$appleLocale');
    localeDir.createSync(recursive: true);
    File('${localeDir.path}/release_notes.txt').writeAsStringSync(note);
  }

  stdout.writeln(
    'Generated ${_targetAppleLocales.length} App Store release notes for version $version in ${outputDir.path}',
  );
}

Map<String, String> _parseArgs(List<String> args) {
  final Map<String, String> parsed = <String, String>{};

  for (int i = 0; i < args.length; i++) {
    final String arg = args[i];
    if (!arg.startsWith('--')) {
      _fail('Unexpected argument: $arg');
    }

    if (arg.contains('=')) {
      final List<String> parts = arg.substring(2).split('=');
      if (parts.length != 2 || parts.first.isEmpty || parts.last.isEmpty) {
        _fail('Invalid argument format: $arg');
      }
      parsed[parts.first] = parts.last;
      continue;
    }

    final String key = arg.substring(2);
    if (i + 1 >= args.length || args[i + 1].startsWith('--')) {
      _fail('Missing value for argument: --$key');
    }
    parsed[key] = args[i + 1];
    i++;
  }

  return parsed;
}

Map<String, dynamic> _readConfig(File notesFile) {
  final String raw = notesFile.readAsStringSync();
  final Object? decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    _fail('Invalid JSON root in ${notesFile.path}. Expected an object.');
  }
  return decoded;
}

String _resolveVersion(String? versionArg) {
  final String? versionFromArg = versionArg?.trim();
  if (versionFromArg != null && versionFromArg.isNotEmpty) {
    return _normalizeVersion(versionFromArg);
  }

  final String? refName = Platform.environment['GITHUB_REF_NAME']?.trim();
  if (refName != null && refName.isNotEmpty) {
    return _normalizeVersion(refName);
  }

  return _readVersionFromPubspec();
}

String _normalizeVersion(String raw) {
  final String candidate = raw.startsWith('v') ? raw.substring(1) : raw;
  final String clean = candidate.split('+').first;
  if (!RegExp(
    r'^[0-9]+\.[0-9]+\.[0-9]+(?:[-+][0-9A-Za-z.-]+)?$',
  ).hasMatch(clean)) {
    _fail('Invalid version value: "$raw"');
  }
  return clean;
}

String _readVersionFromPubspec() {
  final File pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    _fail('pubspec.yaml not found and no version provided.');
  }

  final List<String> lines = pubspec.readAsLinesSync();
  final RegExp versionRegex = RegExp(r'^version:\s*([^\s#]+)');

  for (final String line in lines) {
    final Match? match = versionRegex.firstMatch(line.trim());
    if (match != null) {
      final String rawVersion = match.group(1)!;
      return _normalizeVersion(rawVersion);
    }
  }

  _fail('Could not find a version entry in pubspec.yaml.');
}

void _validateSourceNotes({
  required String version,
  required Map<String, dynamic> notes,
}) {
  final Set<String> providedLocales = notes.keys.toSet();
  final Set<String> missingLocales = _requiredSourceLocales.toSet().difference(
    providedLocales,
  );
  if (missingLocales.isNotEmpty) {
    _fail(
      'Missing required locales for version $version: ${missingLocales.toList()..sort()}',
    );
  }

  for (final String locale in _requiredSourceLocales) {
    final Object? value = notes[locale];
    if (value is! String || value.trim().isEmpty) {
      _fail(
        'Locale $locale for version $version must contain a non-empty text.',
      );
    }
  }
}

void _clearGeneratedLocaleDirs(Directory outputDir) {
  for (final FileSystemEntity entity in outputDir.listSync()) {
    if (entity is Directory) {
      final String dirName = entity.path.split(Platform.pathSeparator).last;
      if (_targetAppleLocales.contains(dirName) || dirName == 'default') {
        entity.deleteSync(recursive: true);
      }
    }
  }
}

Never _fail(String message) {
  stderr.writeln('ERROR: $message');
  exit(1);
}
