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

const List<String> _requiredLocales = <String>[
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

final Set<String> _allowedLocales = _requiredLocales.toSet();

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
    options['output'] ?? 'distribution/whatsnew',
  );

  final Map<String, dynamic> config = _readConfig(notesFile);
  final Object? rawNotes = config[version];
  if (rawNotes is! Map<String, dynamic>) {
    _fail(
      'No release notes found for version "$version" in ${notesFile.path}.',
    );
  }

  _validateNotes(version: version, notes: rawNotes);

  outputDir.createSync(recursive: true);
  for (final FileSystemEntity entity in outputDir.listSync()) {
    if (entity is File &&
        entity.path
            .split(Platform.pathSeparator)
            .last
            .startsWith('whatsnew-')) {
      entity.deleteSync();
    }
  }

  for (final String locale in _requiredLocales) {
    final String note = (rawNotes[locale] as String).trim();
    final File file = File('${outputDir.path}/whatsnew-$locale');
    file.writeAsStringSync(note);
  }

  stdout.writeln(
    'Generated ${_requiredLocales.length} whatsnew files for version $version in ${outputDir.path}',
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

void _validateNotes({
  required String version,
  required Map<String, dynamic> notes,
}) {
  final Set<String> providedLocales = notes.keys.toSet();
  final Set<String> missingLocales = _allowedLocales.difference(
    providedLocales,
  );
  if (missingLocales.isNotEmpty) {
    _fail(
      'Missing required locales for version $version: ${missingLocales.toList()..sort()}',
    );
  }

  final Set<String> unsupportedLocales = providedLocales.difference(
    _allowedLocales,
  );
  if (unsupportedLocales.isNotEmpty) {
    _fail(
      'Unsupported locales found for version $version: ${unsupportedLocales.toList()..sort()}',
    );
  }

  for (final String locale in _requiredLocales) {
    final Object? value = notes[locale];
    if (value is! String || value.trim().isEmpty) {
      _fail(
        'Locale $locale for version $version must contain a non-empty text.',
      );
    }
  }
}

Never _fail(String message) {
  stderr.writeln('ERROR: $message');
  exit(1);
}
