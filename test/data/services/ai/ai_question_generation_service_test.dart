import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/data/services/ai/ai_question_generation_service.dart';

void main() {
  group('AiQuestionGenerationService - Prompt Building', () {
    late AiQuestionGenerationService service;

    setUp(() {
      service = AiQuestionGenerationService();
    });

    test('buildPrompt includes theory specific instructions', () {
      const config = AiQuestionGenerationConfig(
        questionTypes: [AiQuestionType.multipleChoice],
        language: 'en',
        content: 'Newton\'s laws of motion',
        generationCategory: AiGenerationCategory.theory,
      );

      final prompt = service.buildPrompt(config);

      expect(prompt, contains('CONCEPTUAL FOCUS'));
      expect(
        prompt,
        contains('strictly about theory, concepts, definitions, and facts'),
      );
      expect(
        prompt,
        contains('DO NOT ask questions about the exercises themselves'),
      );
      expect(prompt, contains('NO DIRECT REFERENCES'));
    });

    test('buildPrompt includes exercise specific instructions', () {
      const config = AiQuestionGenerationConfig(
        questionTypes: [AiQuestionType.multipleChoice],
        language: 'en',
        content: 'Solve for x in 2x + 5 = 15',
        generationCategory: AiGenerationCategory.exercises,
      );

      final prompt = service.buildPrompt(config);

      expect(prompt, contains('PRACTICAL FOCUS'));
      expect(prompt, contains('generate NEW exercises'));
      expect(prompt, contains('DO NOT reuse them directly'));
      expect(prompt, contains('NO DIRECT REFERENCES'));
    });

    test('buildPrompt includes mixed mode instructions', () {
      const config = AiQuestionGenerationConfig(
        questionTypes: [AiQuestionType.multipleChoice],
        language: 'en',
        content: 'Photosynthesis',
        generationCategory: AiGenerationCategory.both,
      );

      final prompt = service.buildPrompt(config);

      expect(prompt, contains('BALANCED FOCUS'));
      expect(
        prompt,
        contains('mix of theoretical concepts and NEW practical exercises'),
      );
      expect(prompt, contains('DO NOT reference or reuse existing exercises'));
      expect(prompt, contains('NO DIRECT REFERENCES'));
    });

    test('buildPrompt handles file content header correctly', () {
      const config = AiQuestionGenerationConfig(
        questionTypes: [AiQuestionType.multipleChoice],
        language: 'es',
        content: 'Some comments',
        // file: ... (mocking file is harder, but we can check if it uses the text when hasFile is false)
      );

      final prompt = service.buildPrompt(config);
      expect(prompt, contains('Based on the following content'));
      expect(prompt, contains('CONTENT:'));
    });
  });
}
