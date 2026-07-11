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

import 'package:flutter_test/flutter_test.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';

void main() {
  group('QuizFile with Study Model Data', () {
    late Map<String, dynamic> jsonMap;
    late String filePath;

    setUpAll(() async {
      final file = File('sample.quiz');
      if (!await file.exists()) {
        fail('sample.quiz not found. Make sure tests run from project root.');
      }
      final content = await file.readAsString();
      jsonMap = jsonDecode(content) as Map<String, dynamic>;
      filePath = file.path;
    });

    test('should parse correctly into Dart Models', () {
      final quizFile = QuizFile.fromJson(jsonMap, filePath: filePath);

      expect(quizFile.metadata.title, 'Comprehensive Quiz (Long & Short)');
      expect(quizFile.questions.length, 11);
      expect(quizFile.study, isNotNull);

      final studyContent = quizFile.study!.content;
      expect(studyContent.progressPercentage, 100.0);
      expect(studyContent.totalChunks, 11);
      expect(studyContent.cache.length, 11);

      final firstChunk = studyContent.cache.first;
      expect(firstChunk.status, StudyChunkState.completed);
      expect(firstChunk.pages.length, 1);
    });

    test('should serialize maintaining study property', () {
      final quizFile = QuizFile.fromJson(jsonMap, filePath: filePath);
      final serializedJson = quizFile.toJson();

      expect(serializedJson.containsKey('study'), true);

      // We can also perform a deeper equivalence check comparing
      // the reserialized version vs the original parsed structure
      final reserializedQuizFile = QuizFile.fromJson(
        serializedJson,
        filePath: filePath,
      );
      expect(reserializedQuizFile, equals(quizFile));
    });

    test('StudyComponent.fromJson parsing test', () {
      final pJson = {'type': 'paragraph', 'title': 'Intro', 'body': 'Hello'};
      var comp = StudyComponent.fromJson(pJson);
      expect(comp.componentType, StudyComponentType.paragraph);
      expect(comp.props['title'], 'Intro');
      expect(comp.props['body'], 'Hello');

      // Test suffix removal and capitalisation normalization
      final componentWithSuffix = {
        'type': 'ParagraphComponent',
        'body': 'Hello',
      };
      comp = StudyComponent.fromJson(componentWithSuffix);
      expect(comp.componentType, StudyComponentType.paragraph);

      final snakeCaseWithSuffix = {
        'type': 'paragraph_component',
        'body': 'Hello',
      };
      comp = StudyComponent.fromJson(snakeCaseWithSuffix);
      expect(comp.componentType, StudyComponentType.paragraph);

      final kebabCaseComponent = {'type': 'pros-cons', 'pros': [], 'cons': []};
      comp = StudyComponent.fromJson(kebabCaseComponent);
      expect(comp.componentType, StudyComponentType.prosCons);

      final pascalCaseComponent = {
        'type': 'ProsConsComponent',
        'pros': [],
        'cons': [],
      };
      comp = StudyComponent.fromJson(pascalCaseComponent);
      expect(comp.componentType, StudyComponentType.prosCons);

      final componentKeyVariant = {'component': 'paragraph', 'body': 'Hello'};
      comp = StudyComponent.fromJson(componentKeyVariant);
      expect(comp.componentType, StudyComponentType.paragraph);
      expect(comp.props['body'], 'Hello');
      expect(comp.props.containsKey('component'), isFalse);
    });
  });
}
