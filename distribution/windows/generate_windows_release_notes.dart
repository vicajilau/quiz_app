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

void main(List<String> args) {
  final Map<String, String> options = _parseArgs(args);

  final File notesFile = File(
    options['input'] ?? 'distribution/release_notes.json',
  );
  if (!notesFile.existsSync()) {
    _fail('Release notes file not found: ${notesFile.path}');
  }

  final String version = _resolveVersion(options['version']);
  final _ProjectInfo projectInfo = _readProjectInfo();
  final File outputFile = File(
    options['output'] ?? 'distribution/windows/update_metadata.json',
  );

  final Map<String, dynamic> config = _readConfig(notesFile);
  final Object? rawNotes = config[version];
  if (rawNotes is! Map<String, dynamic>) {
    _fail(
      'No release notes found for version "$version" in ${notesFile.path}.',
    );
  }

  _validateNotes(version: version, notes: rawNotes);

  final File currentMetadataFile = File(
    options['current'] ?? 'distribution/windows/current_metadata.json',
  );
  if (!currentMetadataFile.existsSync()) {
    _fail(
      'Current metadata file not found: ${currentMetadataFile.path}. Make sure to run `msstore submission get` first.',
    );
  }

  // Parse current metadata, ignoring any non-JSON prefixes outputted by msstore CLI just in case
  String rawCurrent = currentMetadataFile.readAsStringSync();
  final int jsonStartIndex = rawCurrent.indexOf('{');
  if (jsonStartIndex != -1 && jsonStartIndex > 0) {
    rawCurrent = rawCurrent.substring(jsonStartIndex);
  }

  final Object? decoded = jsonDecode(rawCurrent);
  if (decoded is! Map<String, dynamic>) {
    _fail('Current metadata is not a valid JSON object.');
  }
  final Map<String, dynamic> currentMetadata = decoded;

  final String listingsKey = currentMetadata.keys.firstWhere(
    (k) => k.toLowerCase() == 'listings',
    orElse: () => 'listings',
  );
  currentMetadata[listingsKey] ??= <String, dynamic>{};
  final Map<String, dynamic> currentListings =
      currentMetadata[listingsKey] as Map<String, dynamic>;

  for (final String locale in _requiredLocales) {
    final String note = (rawNotes[locale] as String).trim();
    final String windowsLocale = locale.toLowerCase();

    final String actualLocaleKey = currentListings.keys.firstWhere(
      (k) => k.toLowerCase() == windowsLocale,
      orElse: () => windowsLocale,
    );

    currentListings[actualLocaleKey] ??= <String, dynamic>{};
    final Map<String, dynamic> localeListing =
        currentListings[actualLocaleKey] as Map<String, dynamic>;

    final String baseListingKey = localeListing.keys.firstWhere(
      (k) => k.toLowerCase() == 'baselisting',
      orElse: () => 'baseListing',
    );

    localeListing[baseListingKey] ??= <String, dynamic>{};
    final Map<String, dynamic> baseListing =
        localeListing[baseListingKey] as Map<String, dynamic>;

    // Update fields
    baseListing['title'] = projectInfo.title;
    baseListing['description'] = projectInfo.description;
    baseListing['releaseNotes'] = note;
  }

  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(currentMetadata),
  );

  stdout.writeln(
    'Generated Windows update metadata for version $version in ${outputFile.path}',
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

_ProjectInfo _readProjectInfo() {
  final File pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    return const _ProjectInfo(title: 'Quizdy', description: 'Quizdy');
  }

  final List<String> lines = pubspec.readAsLinesSync();
  String? projectName;
  String? projectDescription;

  for (final String line in lines) {
    final String trimmedLine = line.trim();

    if (projectName == null) {
      final Match? nameMatch = RegExp(
        r'^name:\s*([^\s#]+)',
      ).firstMatch(trimmedLine);
      if (nameMatch != null) {
        projectName = nameMatch.group(1);
        continue;
      }
    }

    if (projectDescription == null) {
      final Match? descriptionMatch = RegExp(
        r'^description:\s*"?(.+?)"?$',
      ).firstMatch(trimmedLine);
      if (descriptionMatch != null) {
        projectDescription = descriptionMatch.group(1)?.trim();
      }
    }
  }

  final String title = _titleCase(projectName ?? 'Quizdy');
  final String description = projectDescription?.isNotEmpty == true
      ? projectDescription!
      : title;

  return _ProjectInfo(title: title, description: description);
}

String _titleCase(String value) {
  if (value.isEmpty) {
    return value;
  }

  return value[0].toUpperCase() + value.substring(1);
}

String _resolveVersion(String? versionArg) {
  final String? versionFromArg = versionArg?.trim();
  if (versionFromArg != null && versionFromArg.isNotEmpty) {
    final String? normalized = _normalizeVersion(versionFromArg);
    if (normalized != null) return normalized;
  }

  final String? refName = Platform.environment['GITHUB_REF_NAME']?.trim();
  if (refName != null && refName.isNotEmpty) {
    final String? normalized = _normalizeVersion(refName);
    if (normalized != null) return normalized;
  }

  return _readVersionFromPubspec();
}

String? _normalizeVersion(String raw) {
  final String candidate = raw.startsWith('v') ? raw.substring(1) : raw;
  final String clean = candidate.split('+').first;
  if (!RegExp(
    r'^[0-9]+\.[0-9]+\.[0-9]+(?:[-+][0-9A-Za-z.-]+)?$',
  ).hasMatch(clean)) {
    return null;
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
      final String? normalized = _normalizeVersion(rawVersion);
      if (normalized != null) return normalized;
    }
  }

  _fail('Could not find a version entry in pubspec.yaml.');
}

void _validateNotes({
  required String version,
  required Map<String, dynamic> notes,
}) {
  final Set<String> providedLocales = notes.keys.toSet();
  final Set<String> missingLocales = _requiredLocales.toSet().difference(
    providedLocales,
  );
  if (missingLocales.isNotEmpty) {
    _fail(
      'Missing required locales for version $version: ${missingLocales.toList()..sort()}',
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

class _ProjectInfo {
  const _ProjectInfo({required this.title, required this.description});

  final String title;
  final String description;
}
