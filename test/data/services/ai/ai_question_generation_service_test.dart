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

import 'package:flutter_test/flutter_test.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/domain/repositories/ai_repository.dart';
import 'package:quizdy/data/repositories/ai/ai_repository_factory.dart';
import 'package:quizdy/data/services/ai/ai_question_generation_service.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_file_upload_result.dart';
import 'package:quizdy/domain/models/ai/ai_generation_config.dart';
import 'package:quizdy/domain/models/ai/ai_question_type.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/quiz/source_reference.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import '../../../helpers/test_service_locator.dart';

class FakeAiRepository implements AiRepository {
  final String mockResponse;
  FakeAiRepository(this.mockResponse);

  @override
  String get providerId => 'fake_provider';

  @override
  String get modelId => 'fake_model';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String> sendMessages(
    String prompt,
    AppLocalizations localizations, {
    String? responseMimeType,
  }) async {
    return mockResponse;
  }

  @override
  Future<String> sendMessagesWithFile(
    String prompt,
    AppLocalizations localizations, {
    required AiFileAttachment file,
    String? responseMimeType,
  }) async {
    return mockResponse;
  }

  @override
  Future<AiFileUploadResult> uploadFile(
    AiFileAttachment file,
    AppLocalizations localizations,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<String> sendMessagesWithFileUri(
    String prompt,
    AppLocalizations localizations, {
    required String fileUri,
    required String fileMimeType,
    String? responseMimeType,
  }) async {
    return mockResponse;
  }
}

class FakeAiRepositoryFactory implements AiRepositoryFactory {
  final FakeAiRepository repository;
  FakeAiRepositoryFactory(this.repository);

  @override
  Future<AiRepository> createDefault() async => repository;

  @override
  AiRepository createForModel(String model) => repository;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAppLocalizations implements AppLocalizations {
  @override
  String get aiPrompt => 'System Prompt';
  @override
  String get aiChatGuardrail => 'Guardrail';
  @override
  String get questionLabel => 'Question';
  @override
  String get optionsLabel => 'Options';
  @override
  String get explanationLabel => 'Explanation';
  @override
  String get studentComment => 'Student';
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await setUpTestServiceLocator();
  });

  tearDown(() {
    tearDownTestServiceLocator();
  });

  test('AiQuestionGenerationService parses studySectionId from JSON successfully', () async {
    const sectionId = 'chunk_123456789';
    const mockJson = '''
    [
      {
        "text": "What is the capital of France?",
        "type": "single_choice",
        "options": ["Paris", "London", "Berlin", "Madrid"],
        "correctAnswers": [0],
        "explanation": "Paris is the capital.",
        "studySectionId": "$sectionId"
      }
    ]
    ''';

    final fakeRepo = FakeAiRepository(mockJson);
    final fakeFactory = FakeAiRepositoryFactory(fakeRepo);

    final getIt = ServiceLocator.getIt;
    getIt.registerSingleton<AiRepositoryFactory>(fakeFactory);

    final config = const AiQuestionGenerationConfig(
      questionTypes: [AiQuestionType.singleChoice],
      language: 'en',
      content: 'France info',
      selectedChunks: [
        StudyChunk(
          id: sectionId,
          chunkIndex: 0,
          status: StudyChunkState.completed,
          pages: [],
          sourceReference: SourceReference(
            documentId: 'doc1',
            startPage: 1,
            endPage: 2,
            startOffset: 0,
            endOffset: 100,
            blockType: 'Section 1',
          ),
        ),
      ],
    );

    final service = AiQuestionGenerationService(
      configurationService: getIt(),
    );

    final questions = await service.generateQuestions(
      config,
      localizations: MockAppLocalizations(),
    );

    expect(questions.length, 1);
    expect(questions.first.text, 'What is the capital of France?');
    expect(questions.first.studySectionId, sectionId);

    getIt.unregister<AiRepositoryFactory>();
  });
}
