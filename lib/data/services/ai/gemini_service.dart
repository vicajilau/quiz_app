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
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/data/services/ai/ai_service.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/ai/ai_study_generation_config.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/domain/models/custom_exceptions/connectivity_exception.dart';

class GeminiService extends AIService {
  static const String _baseUrlBeta =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _uploadBaseUrlBeta =
      'https://generativelanguage.googleapis.com/upload/v1beta';
  static const String _baseUrlAlpha =
      'https://generativelanguage.googleapis.com/v1alpha';
  static const String _defaultModel = 'gemini-flash-latest';

  static const List<String> _models = [
    'gemini-flash-latest',
    'gemini-3.1-pro-preview',
    'gemini-3-flash-preview',
    'gemini-2.5-pro',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
  ];

  GeminiService({required this.dioClient, required this.configurationService});

  final Dio dioClient;
  final ConfigurationService configurationService;

  @override
  String get serviceName => 'Google Gemini';

  @override
  String get defaultModel => _defaultModel;

  @override
  List<String> get availableModels => _models;

  String _extractErrorDetail(DioException e, AppLocalizations localizations) {
    final data = e.response?.data;
    if (data != null &&
        data['error'] != null &&
        data['error']['message'] != null) {
      return '${localizations.aiErrorResponse} ${data['error']['message']}';
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == null) {
      return localizations.aiErrorResponse;
    }
    return '${localizations.aiErrorResponse} ($statusCode)';
  }

  Exception _buildDioException(DioException e, AppLocalizations localizations) {
    if (e.error is ConnectivityException) {
      final ce = e.error as ConnectivityException;
      return Exception(
        ce.type == ConnectivityExceptionType.connectionAborted
            ? localizations.aiErrorConnectionAborted
            : localizations.noInternetConnection,
      );
    }

    if (e.response?.statusCode == 302) {
      final location = e.response?.headers['location']?.first;
      return Exception(localizations.aiErrorRedirect(location ?? ''));
    } else if (e.response?.statusCode == 400) {
      return Exception(_extractErrorDetail(e, localizations));
    } else if (e.response?.statusCode == 403) {
      return Exception(localizations.invalidApiKeyError);
    } else if (e.response?.statusCode == 429) {
      return Exception(localizations.rateLimitError);
    } else {
      return Exception(_extractErrorDetail(e, localizations));
    }
  }

  @override
  Future<bool> isAvailable() async {
    final apiKey = await configurationService.getGeminiApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Realiza una petición a la API de Gemini
  @override
  Future<String> getChatResponse(
    String prompt,
    AppLocalizations localizations, {
    String? model,
    String? responseMimeType,
  }) async {
    final apiKey = await configurationService.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;

    final baseUrl = selectedModel == 'gemini-3.1-pro-preview'
        ? _baseUrlAlpha
        : _baseUrlBeta;
    final url = '$baseUrl/models/$selectedModel:generateContent?key=$apiKey';

    try {
      final response = await dioClient.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.2, 'topK': 5, 'topP': 0.95},
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        },
      );

      final jsonResponse = response.data;
      final candidates = jsonResponse['candidates'] as List?;

      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content']['parts'][0]['text'];
        return content?.toString().trim() ?? localizations.noResponseReceived;
      } else {
        return localizations.noResponseReceived;
      }
    } on DioException catch (e) {
      throw _buildDioException(e, localizations);
    } catch (e) {
      throw Exception(localizations.networkErrorGemini);
    }
  }

  @override
  Future<String> getChatResponseWithFile(
    String prompt,
    AppLocalizations localizations, {
    String? model,
    String? responseMimeType,
    required AiFileAttachment file,
  }) async {
    final uploadResult = await uploadFile(file, localizations);

    return getChatResponseWithFileUri(
      prompt,
      localizations,
      model: model,
      responseMimeType: responseMimeType,
      fileUri: uploadResult.fileUri,
      fileMimeType: file.mimeType,
    );
  }

  @override
  Future<FileUploadResult> uploadFile(
    AiFileAttachment file,
    AppLocalizations localizations,
  ) async {
    final apiKey = await configurationService.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final url = '$_uploadBaseUrlBeta/files?key=$apiKey';

    try {
      final boundary =
          '--------------------------${DateTime.now().millisecondsSinceEpoch}';

      final List<int> metadata = utf8.encode(
        '--$boundary\r\n'
        'Content-Type: application/json; charset=UTF-8\r\n\r\n'
        '{"file": {"displayName": "${file.name}"}}\r\n'
        '--$boundary\r\n'
        'Content-Type: ${file.mimeType}\r\n\r\n',
      );

      final List<int> footer = utf8.encode('\r\n--$boundary--\r\n');

      final body = Uint8List.fromList([...metadata, ...file.bytes, ...footer]);

      final response = await dioClient.post(
        url,
        options: Options(
          headers: {
            'X-Goog-Upload-Protocol': 'multipart',
            'Content-Type': 'multipart/related; boundary=$boundary',
            'Content-Length': '${body.length}',
          },
        ),
        data: body,
      );

      final jsonResponse = response.data;
      final fileUri = jsonResponse['file']?['uri'] as String?;
      final expirationTimeStr =
          jsonResponse['file']?['expirationTime'] as String?;

      if (fileUri != null && expirationTimeStr != null) {
        return FileUploadResult(
          fileUri: fileUri,
          expirationTime: DateTime.parse(expirationTimeStr),
        );
      } else {
        throw Exception(localizations.noResponseReceived);
      }
    } on DioException catch (e) {
      throw _buildDioException(e, localizations);
    } catch (e) {
      throw Exception(localizations.networkErrorGemini);
    }
  }

  @override
  Future<String> getChatResponseWithFileUri(
    String prompt,
    AppLocalizations localizations, {
    String? model,
    String? responseMimeType,
    required String fileUri,
    required String fileMimeType,
  }) async {
    final apiKey = await configurationService.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;

    final baseUrl = selectedModel == 'gemini-3.1-pro-preview'
        ? _baseUrlAlpha
        : _baseUrlBeta;
    final url = '$baseUrl/models/$selectedModel:generateContent?key=$apiKey';

    try {
      final response = await dioClient.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'file_data': {'mime_type': fileMimeType, 'file_uri': fileUri},
                },
              ],
            },
          ],
          'generationConfig': {
            'responseMimeType': ?responseMimeType,
            'temperature': 0.2,
            'topK': 5,
            'topP': 0.95,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        },
      );

      final jsonResponse = response.data;
      final candidates = jsonResponse['candidates'] as List?;

      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content']['parts'][0]['text'];
        return content?.toString().trim() ?? localizations.noResponseReceived;
      } else {
        return localizations.noResponseReceived;
      }
    } on DioException catch (e) {
      throw _buildDioException(e, localizations);
    } catch (e) {
      throw Exception(localizations.networkErrorGemini);
    }
  }

  @override
  Future<String> generateStudyIndex(
    AppLocalizations localizations, {
    required String fileUri,
    required String fileMimeType,
    String? extraContext,
    required String language,
  }) async {
    final commentsSection =
        extraContext != null && extraContext.trim().isNotEmpty
        ? '\nADDITIONAL INSTRUCTIONS/CONTEXT FROM THE USER:\n$extraContext\n'
        : '';

    final targetLanguage = language;

    final prompt =
        '''
Act as an expert academic educator. Analyze the provided document $commentsSection and generate a structured study guide with a Table of Contents for a personalized study plan.

IMPORTANT GLOBAL RULE:
ALL fields in the JSON output (title, description, chapter titles, summaries) MUST be written strictly in the following language: $targetLanguage.

Rules:
1. Generate a concise title that summarizes the subject matter of the syllabus. Do NOT reference the document itself (e.g. avoid "Document about...", "This PDF covers..."). Just state the topic directly.
2. Generate a brief description (2-3 sentences) explaining the syllabus content and its key learning objectives. Write it as if describing the subject, not the document.
3. Divide the content into logical "Themes" or "Chapters" (chunks).
4. Each theme should be granular enough to be studied in a single session.
5. If a section is very long, break it down into sub-themes.
6. For each theme, identify the start and end page (if the document has pages/is a PDF). If not, use estimated percentages or indices.
7. High Priority: Chunks should feel like an index of a book.
8. Themes should be logically treated as the main units of study.
9. Output ONLY a valid JSON object with this structure:
{
  "title": "Subject Title",
  "description": "Brief 2-3 sentence description of the syllabus and learning objectives.",
  "chapters": [
    {
      "title": "Theme Title",
      "startPage": 1,
      "endPage": 3,
      "summary": "Brief 1-sentence description of the topic covered. Do not reference the document."
    }
  ]
}
''';

    return getChatResponseWithFileUri(
      prompt,
      localizations,
      responseMimeType: 'application/json',
      fileUri: fileUri,
      fileMimeType: fileMimeType,
    );
  }

  @override
  Future<String> generateStudyIndexFromText(
    AppLocalizations localizations, {
    required String content,
    required AiGenerationMode generationMode,
    required String language,
    List<Question>? selectedQuestions,
  }) async {
    final header = selectedQuestions != null && selectedQuestions.isNotEmpty
        ? '''
The user wants a personalized study plan based on the following selected quiz questions:

${_buildSelectedQuestionsContent(selectedQuestions)}

Use these questions to infer the concepts, topics, skills, and knowledge areas that should be covered in the study plan.
'''
        : generationMode == AiGenerationMode.topic
        ? 'The user wants a personalized study plan about the following topic/s: $content'
        : 'The user has provided the following text for creating a study plan:\n\n$content';

    final targetLanguage = language;

    final prompt =
        '''
Act as an expert academic educator. $header

Analyze the content and generate a structured study guide with a Table of Contents for a personalized study plan.

IMPORTANT GLOBAL RULE:
ALL fields in the JSON output (title, description, chapter titles, summaries) MUST be written strictly in the following language: $targetLanguage.

Rules:
1. Generate a concise title that summarizes the subject matter.
2. Generate a brief description (2-3 sentences) explaining the syllabus content and its key learning objectives.
3. Divide the content into logical "Themes" or "Chapters" (chunks).
4. Each theme should be granular enough to be studied in a single session.
5. Themes should be logically treated as the main units of study.
6. Output ONLY a valid JSON object with this structure:
{
  "title": "Subject Title",
  "description": "Brief 2-3 sentence description of the syllabus and learning objectives.",
  "chapters": [
    {
      "title": "Theme Title",
      "summary": "Brief 1-sentence description of the topic covered."
    }
  ]
}
''';

    return getChatResponse(
      prompt,
      localizations,
      responseMimeType: 'application/json',
    );
  }

  /// Generates a list of [StudyComponent]s from an [AiStudyGenerationConfig].
  ///
  /// Returns the components to be added directly to a study page.
  Future<List<StudyComponent>> generatePageComponents(
    AppLocalizations localizations,
    AiStudyGenerationConfig config,
  ) async {
    final prompt = _buildPageComponentsPrompt(config, localizations);

    final String responseBody;
    if (config.hasFile) {
      responseBody = await getChatResponseWithFile(
        prompt,
        localizations,
        model: config.preferredModel,
        responseMimeType: 'application/json',
        file: config.file!,
      );
    } else {
      responseBody = await getChatResponse(
        prompt,
        localizations,
        model: config.preferredModel,
        responseMimeType: 'application/json',
      );
    }

    final cleanJson = _extractJsonArrayFromResponse(responseBody);
    final decoded = jsonDecode(cleanJson);
    if (decoded is! List) {
      throw FormatException(
        'Expected a JSON array of components. Got: $cleanJson',
      );
    }
    return decoded
        .map((e) => StudyComponent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _buildPageComponentsPrompt(
    AiStudyGenerationConfig config,
    AppLocalizations localizations,
  ) {
    final targetLanguage = config.language;

    String difficultyInstruction = '';
    if (!config.isAutoDifficulty && config.difficultyLevel != null) {
      final levelName = config.difficultyLevel!.localizedName(localizations);
      difficultyInstruction =
          '\nIMPORTANT: The content MUST be adapted to a $levelName difficulty level.';
    } else if (config.isAutoDifficulty) {
      difficultyInstruction =
          '\nIMPORTANT: Adapt the content difficulty to match the provided material.';
    }

    final allowedTypes = config.allowedComponentTypes;
    final typeConstraint = allowedTypes != null
        ? '\nIMPORTANT: You MUST ONLY use the following component types: '
              '${allowedTypes.map((t) => t.name).join(', ')}. Do not use any other types.'
        : '';

    final contentHeader = config.generationMode == AiGenerationMode.topic
        ? 'Topic to cover: ${config.content}'
        : 'Source text:\n${config.content}';

    return '''
You are an expert educational content generator. Generate study components based on the provided content.

IMPORTANT GLOBAL RULE:
ALL generated content MUST be written strictly in the following language: $targetLanguage.
$difficultyInstruction$typeConstraint

Return ONLY a valid JSON array of component objects. Do not include any other text, markdown formatting (like ```json), or explanations.

Each element in the array MUST have a "type" field and its specific required fields. Allowed component types:
1. { "type": "section_title", "title": "Main topic", "subtitle": "Optional context" }
2. { "type": "paragraph", "title": "Optional heading", "body": "Main text block" }
3. { "type": "key_definition", "term": "Vocabulary word/concept", "body": "Clear definition" }
4. { "type": "numbered_list", "title": "Optional heading", "items": [{"title": "Step 1", "description": "Details"}] }
5. { "type": "comparison_table", "title": "Optional", "columns": ["Feature", "A", "B"], "rows": [{"label": "Row 1", "values": ["A val", "B val"]}] }
6. { "type": "quote", "body": "The quote text", "author": "Optional source" }
7. { "type": "warning", "body": "Important caveat or common misconception" }
8. { "type": "formula", "title": "Optional", "equation": "E = mc^2", "equation_label": "Optional name", "body": "Explanation" }
9. { "type": "timeline", "title": "Optional", "items": [{"date": "1990", "title": "Event", "description": "Optional details"}] }
10. { "type": "pros_cons", "items": {"pros": ["Advantage 1"], "cons": ["Disadvantage 1"]} }
11. { "type": "key_concepts", "title": "Optional", "items": ["Concept 1", "Concept 2"] }
12. { "type": "reminder", "body": "A quick tip or study reminder" }
13. { "type": "icon_cards", "title": "Optional", "items": [{"title": "Card title", "description": "Card details"}] }

$contentHeader
''';
  }

  /// Extracts a JSON array string from the LLM response, stripping markdown if present.
  String _extractJsonArrayFromResponse(String response) {
    final regExp = RegExp(r'```json\s*([\s\S]*?)\s*```', multiLine: true);
    final match = regExp.firstMatch(response);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim();
    }
    final firstBracket = response.indexOf('[');
    final lastBracket = response.lastIndexOf(']');
    if (firstBracket != -1 && lastBracket != -1 && lastBracket > firstBracket) {
      return response.substring(firstBracket, lastBracket + 1).trim();
    }
    return response.trim();
  }

  String _buildSelectedQuestionsContent(List<Question> questions) {
    final buffer = StringBuffer();

    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];
      buffer.writeln('Question ${i + 1}: ${question.text}');

      if (question.options.isNotEmpty) {
        buffer.writeln('Options:');
        for (final option in question.options) {
          buffer.writeln('- $option');
        }
      }

      if (question.explanation.isNotEmpty) {
        buffer.writeln('Explanation: ${question.explanation}');
      }

      buffer.writeln();
    }

    return buffer.toString().trim();
  }
}
