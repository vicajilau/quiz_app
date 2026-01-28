import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../data/services/configuration_service.dart';
import '../../../../data/services/ai/ai_service.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../domain/models/quiz/question.dart';
import '../../../../domain/models/quiz/question_type.dart';

// Extended enum to include the "random" option
enum AiQuestionType {
  multipleChoice,
  singleChoice,
  trueFalse,
  essay,
  random, // Mix of all types
}

// Class for generation configuration
class AiQuestionGenerationConfig {
  final int? questionCount;
  final List<AiQuestionType> questionTypes;
  final String language;
  final String content;
  final AIService? preferredService; // Preferred AI service
  final String? preferredModel; // Preferred model for the service

  const AiQuestionGenerationConfig({
    this.questionCount,
    required this.questionTypes,
    required this.language,
    required this.content,
    this.preferredService,
    this.preferredModel,
  });
}

class AiQuestionGenerationService {
  static const String _openaiApiUrl =
      'https://api.openai.com/v1/chat/completions';
  static const String _geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent';

  /// Generates questions using AI based on the provided configuration
  Future<List<Question>> generateQuestions(
    AiQuestionGenerationConfig config, {
    AppLocalizations? localizations,
  }) async {
    try {
      // If a preferred service is specified, use it directly
      if (config.preferredService != null && localizations != null) {
        return await _generateWithService(
          config,
          config.preferredService!,
          localizations,
        );
      }

      // Verify that at least one API key is configured
      final openaiKey = await ConfigurationService.instance.getOpenAIApiKey();
      final geminiKey = await ConfigurationService.instance.getGeminiApiKey();

      if ((openaiKey?.isEmpty ?? true) && (geminiKey?.isEmpty ?? true)) {
        throw Exception('No API key configured for AI services');
      }

      // Try OpenAI first, then Gemini if it fails
      if (openaiKey?.isNotEmpty == true) {
        try {
          return await _generateWithOpenAI(config, openaiKey!, localizations!);
        } catch (e) {
          if (geminiKey?.isNotEmpty == true) {
            return await _generateWithGemini(
              config,
              geminiKey!,
              localizations!,
            );
          }
          rethrow;
        }
      } else if (geminiKey?.isNotEmpty == true) {
        return await _generateWithGemini(config, geminiKey!, localizations!);
      }

      throw Exception('Could not generate questions with any AI service');
    } catch (e) {
      rethrow;
    }
  }

  /// Generates questions using the specified AI service
  Future<List<Question>> _generateWithService(
    AiQuestionGenerationConfig config,
    AIService aiService,
    AppLocalizations localizations,
  ) async {
    final prompt = _buildPrompt(config);

    try {
      final response = await aiService.getChatResponse(
        prompt,
        localizations,
        model: config.preferredModel,
      );
      return _parseAiResponse(response);
    } catch (e) {
      rethrow; // Let the service handle its own errors
    }
  }

  /// Generates questions using OpenAI
  Future<List<Question>> _generateWithOpenAI(
    AiQuestionGenerationConfig config,
    String apiKey,
    AppLocalizations localizations,
  ) async {
    final prompt = _buildPrompt(config);

    final response = await http.post(
      Uri.parse(_openaiApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an expert in education who creates high-quality quiz questions. Respond ONLY with the requested JSON, without additional text.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 3000,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(localizations.aiErrorResponse);
    }

    final jsonResponse = jsonDecode(response.body);
    final content = jsonResponse['choices'][0]['message']['content'];

    return _parseAiResponse(content);
  }

  /// Generates questions using Gemini
  Future<List<Question>> _generateWithGemini(
    AiQuestionGenerationConfig config,
    String apiKey,
    AppLocalizations localizations,
  ) async {
    final prompt = _buildPrompt(config);

    final response = await http.post(
      Uri.parse('$_geminiApiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'You are an expert in education who creates high-quality quiz questions. Respond ONLY with the requested JSON, without additional text.\n\n$prompt',
              },
            ],
          },
        ],
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 3000},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(localizations.aiErrorResponse);
    }

    final jsonResponse = jsonDecode(response.body);
    final content =
        jsonResponse['candidates'][0]['content']['parts'][0]['text'];

    return _parseAiResponse(content);
  }

  /// Builds the prompt for the AI
  String _buildPrompt(AiQuestionGenerationConfig config) {
    final questionCountText = config.questionCount != null
        ? 'exactly ${config.questionCount}'
        : 'between 3 and 8';

    final questionTypesText = _getQuestionTypesPrompt(config.questionTypes);
    final languageText = _getLanguageName(config.language);

    return '''
Based on the following content, generate $questionCountText quiz questions $questionTypesText in $languageText.

CONTENT:
${config.content}

INSTRUCTIONS:
1. Questions must be based specifically on the provided content
2. Each question must have exactly 4 answer options
3. Include a clear explanation for each question
4. Make sure incorrect answers are plausible but clearly wrong
5. Explanations should be educational and help understand why the answer is correct

RESPONSE FORMAT (JSON):
Respond ONLY with a valid JSON array in this exact format:
[
  {
    "text": "Question here?",
    "type": "multiple_choice",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctAnswers": [0],
    "explanation": "Detailed explanation of why answer A is correct..."
  }
]

QUESTION TYPES:
- "multiple_choice": Allows multiple correct answers
- "single_choice": Only one correct answer
- "true_false": True/false question (options: ["True", "False"])
- "essay": Essay question (no options)

$questionTypesText

IMPORTANT!: Respond ONLY with the JSON, no additional text before or after.
''';
  }

  /// Gets the prompt text according to the selected question types
  String _getQuestionTypesPrompt(List<AiQuestionType> types) {
    const typePrompts = {
      AiQuestionType.multipleChoice:
          'Use ONLY the "multiple_choice" type for all questions.',
      AiQuestionType.singleChoice:
          'Use ONLY the "single_choice" type for all questions.',
      AiQuestionType.trueFalse:
          'Use ONLY the "true_false" type for all questions. Options must be ["True", "False"].',
      AiQuestionType.essay:
          'Use ONLY the "essay" type for all questions. Do not include options.',
      AiQuestionType.random:
          'Mix different question types: "multiple_choice", "single_choice", "true_false", and "essay".',
    };

    if (types.contains(AiQuestionType.random) || types.isEmpty) {
      return typePrompts[AiQuestionType.random]!;
    }

    if (types.length == 1) {
      return typePrompts[types.first]!;
    }

    final typeNames = types
        .map((t) {
          switch (t) {
            case AiQuestionType.multipleChoice:
              return '"multiple_choice"';
            case AiQuestionType.singleChoice:
              return '"single_choice"';
            case AiQuestionType.trueFalse:
              return '"true_false"';
            case AiQuestionType.essay:
              return '"essay"';
            case AiQuestionType.random:
              return '';
          }
        })
        .where((name) => name.isNotEmpty)
        .join(', ');

    return 'Mix these question types: $typeNames.';
  }

  /// Gets the language name
  String _getLanguageName(String langCode) {
    switch (langCode) {
      case 'es':
        return 'Spanish';
      case 'en':
        return 'English';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'el':
        return 'Greek';
      case 'it':
        return 'Italian';
      case 'pt':
        return 'Portuguese';
      case 'ca':
        return 'Catalan';
      case 'eu':
        return 'Basque';
      case 'gl':
        return 'Galician';
      case 'hi':
        return 'Hindi';
      case 'zh':
        return 'Chinese';
      case 'ar':
        return 'Arabic';
      case 'ja':
        return 'Japanese';
      default:
        return 'English';
    }
  }

  /// Parses the AI response and converts to Question objects
  List<Question> _parseAiResponse(String content) {
    try {
      // Clean the response in case it has additional text
      String cleanContent = content.trim();

      // Search for JSON in the response
      final startIndex = cleanContent.indexOf('[');
      final endIndex = cleanContent.lastIndexOf(']');

      if (startIndex == -1 || endIndex == -1) {
        throw Exception('No valid JSON found in AI response');
      }

      cleanContent = cleanContent.substring(startIndex, endIndex + 1);

      final List<dynamic> jsonList = jsonDecode(cleanContent);
      final List<Question> questions = [];

      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          try {
            final question = _createQuestionFromJson(item);
            questions.add(question);
          } catch (e) {
            // If one question fails, continue with the others
            // In production, use appropriate logging
            continue;
          }
        }
      }

      if (questions.isEmpty) {
        throw Exception('Could not create valid questions from AI response');
      }

      return questions;
    } catch (e) {
      throw Exception('Could not create valid questions from AI response');
    }
  }

  /// Creates a Question object from JSON
  Question _createQuestionFromJson(Map<String, dynamic> json) {
    final questionType = QuestionType.fromString(
      json['type'] ?? 'multiple_choice',
    );

    List<String> options = [];
    if (json['options'] != null) {
      options = List<String>.from(json['options']);
    } else if (questionType == QuestionType.trueFalse) {
      options = ['True', 'False'];
    }

    List<int> correctAnswers = [];
    if (json['correctAnswers'] != null) {
      correctAnswers = List<int>.from(json['correctAnswers']);
    } else if (questionType == QuestionType.trueFalse) {
      // For true/false, assume the first option is correct if not specified
      correctAnswers = [0];
    }

    return Question(
      type: questionType,
      text: json['text'] ?? '',
      options: options,
      correctAnswers: correctAnswers,
      explanation: json['explanation'] ?? '',
      image: null, // AI doesn't generate images for now
    );
  }

  static String buildEvaluationPrompt(
    String questionText,
    String studentAnswer,
    String explanation,
    AppLocalizations localizations,
  ) {
    final hasExplanation = explanation.isNotEmpty;

    String prompt =
        '''
${localizations.aiEvaluationPromptSystemRole}

${localizations.aiEvaluationPromptQuestion}
$questionText

${localizations.aiEvaluationPromptStudentAnswer}
$studentAnswer
''';

    if (hasExplanation) {
      prompt +=
          '''

${localizations.aiEvaluationPromptCriteria}
$explanation

${localizations.aiEvaluationPromptSpecificInstructions}
''';
    } else {
      prompt +=
          '''

${localizations.aiEvaluationPromptGeneralInstructions}
''';
    }

    prompt +=
        '''

${localizations.aiEvaluationPromptResponseFormat}
''';

    return prompt;
  }
}
