// Copyright (C) 2026 Víctor Carreras
//
// Generate or update AppStream metainfo with the English release notes
// extracted from the central distribution/release_notes.json file.

import 'dart:io';
import 'dart:convert';

String _escapeXml(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart distribution/linux/generate_linux_release_notes.dart <version>',
    );
    exit(1);
  }

  final String version = args[0].startsWith('v')
      ? args[0].substring(1)
      : args[0];
  final File notesFile = File('distribution/release_notes.json');
  if (!notesFile.existsSync()) {
    stderr.writeln('distribution/release_notes.json not found.');
    exit(1);
  }

  final Map<String, dynamic> json = jsonDecode(notesFile.readAsStringSync());
  final Map<String, dynamic>? versionMap = (json[version] as Map?)
      ?.cast<String, dynamic>();
  if (versionMap == null) {
    stderr.writeln(
      'No release notes found for version $version in distribution/release_notes.json',
    );
    exit(1);
  }

  // Prefer en-US, then en-GB, then any 'en' key.
  String? notes =
      (versionMap['en-US'] as String?) ??
      (versionMap['en-GB'] as String?) ??
      (versionMap['en'] as String?);
  notes ??=
      versionMap.values.firstWhere((v) => v is String, orElse: () => '')
          as String;
  final String escaped = _escapeXml(notes.trim());

  final File metaFile = File('snap/gui/quiz-app.metainfo.xml');
  if (!metaFile.existsSync()) {
    stderr.writeln(
      'AppStream metadata not found at snap/gui/quiz-app.metainfo.xml, creating a template.',
    );
    metaFile.parent.createSync(recursive: true);
    metaFile.writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>es.victorcarreras.quiz_app</id>
  <name>Quizdy</name>
  <summary>Quizdy — an interactive quiz application</summary>
  <releases>
  </releases>
</component>
''');
  }

  String xml = metaFile.readAsStringSync();

  final String date = DateTime.now().toIso8601String().split('T').first;
  final String releaseBlock =
      '\n    <release version="${_escapeXml(version)}" date="$date">\n      <description>\n        <p>$escaped</p>\n      </description>\n    </release>\n  ';

  if (xml.contains('</releases>')) {
    xml = xml.replaceFirst('</releases>', '$releaseBlock</releases>');
  } else if (xml.contains('<releases>')) {
    xml = xml.replaceFirst('<releases>', '<releases>$releaseBlock');
  } else {
    // append a releases section
    xml = xml.replaceFirst(
      '</component>',
      '  <releases>$releaseBlock  </releases>\n</component>',
    );
  }

  metaFile.writeAsStringSync(xml);
  stdout.writeln(
    'Updated snap/gui/quiz-app.metainfo.xml with release notes for version $version',
  );
}
