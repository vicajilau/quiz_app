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

import 'package:dio/dio.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/openai_content_block.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/data/services/ai/ai_service.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/quiz/question.dart';

class OpenAIService extends AIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _chatEndpoint = '/chat/completions';
  static const String _filesEndpoint = '/files';
  static const String _defaultModel = 'gpt-4o-mini';

  static const List<String> _models = [
    'gpt-4o-mini',
    'gpt-4o',
    'gpt-4-turbo',
    'gpt-4',
    'gpt-3.5-turbo',
  ];

  OpenAIService({required this.dioClient, required this.configurationService});

  final Dio dioClient;
  final ConfigurationService configurationService;

  @override
  String get serviceName => 'OpenAI GPT';

  @override
  String get defaultModel => _defaultModel;

  @override
  List<String> get availableModels => _models;

  @override
  Future<bool> isAvailable() async {
    final apiKey = await configurationService.getOpenAIApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

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
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      final errorStr = e.error.toString();
      if (errorStr.contains('Software caused connection abort') ||
          errorStr.contains('Connection closed')) {
        return Exception(localizations.aiErrorConnectionAborted);
      }
    }

    if (e.response?.statusCode == 401) {
      return Exception(localizations.invalidApiKeyError);
    } else if (e.response?.statusCode == 429) {
      return Exception(localizations.rateLimitError);
    } else if (e.response?.statusCode == 404) {
      return Exception(localizations.modelNotFoundError);
    } else {
      return Exception(_extractErrorDetail(e, localizations));
    }
  }

  /// Realiza una petición a la API de ChatGPT
  @override
  Future<String> getChatResponse(
    String prompt,
    AppLocalizations localizations, {
    String? model,
    String? responseMimeType,
  }) async {
    final apiKey = await configurationService.getOpenAIApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.openaiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;

    try {
      final data = <String, dynamic>{
        'model': selectedModel,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 8192,
        'temperature': 0.2,
      };

      if (responseMimeType == 'application/json') {
        data['response_format'] = {'type': 'json_object'};
      }

      final response = await dioClient.post(
        '$_baseUrl$_chatEndpoint',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: data,
      );

      final jsonResponse = response.data;
      final content = jsonResponse['choices'][0]['message']['content'];
      return content?.toString().trim() ?? localizations.noResponseReceived;
    } on DioException catch (e) {
      throw _buildDioException(e, localizations);
    } catch (e) {
      throw Exception(localizations.networkErrorOpenAI);
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
    final apiKey = await configurationService.getOpenAIApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.openaiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;
    final contentBlocks = OpenAIContentBlock.fromPromptAndFile(prompt, file);

    try {
      final data = <String, dynamic>{
        'model': selectedModel,
        'messages': [
          {
            'role': 'user',
            'content': contentBlocks.map((b) => b.toJson()).toList(),
          },
        ],
        'max_tokens': 8192,
        'temperature': 0.2,
      };

      if (responseMimeType == 'application/json') {
        data['response_format'] = {'type': 'json_object'};
      }

      final response = await dioClient.post(
        '$_baseUrl$_chatEndpoint',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: data,
      );

      final jsonResponse = response.data;
      final content = jsonResponse['choices'][0]['message']['content'];
      return content?.toString().trim() ?? localizations.noResponseReceived;
    } on DioException catch (e) {
      throw _buildDioException(e, localizations);
    } catch (e) {
      throw Exception(localizations.networkErrorOpenAI);
    }
  }

  @override
  Future<FileUploadResult> uploadFile(
    AiFileAttachment file,
    AppLocalizations localizations,
  ) async {
    final apiKey = await configurationService.getOpenAIApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.openaiApiKeyNotConfigured);
    }

    try {
      final formData = FormData.fromMap({
        'purpose': 'assistants',
        'file': MultipartFile.fromBytes(file.bytes, filename: file.name),
      });

      final response = await dioClient.post(
        '$_baseUrl$_filesEndpoint',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: formData,
      );

      final jsonResponse = response.data;
      final fileId = jsonResponse['id'] as String?;

      if (fileId == null || fileId.isEmpty) {
        throw Exception(localizations.noResponseReceived);
      }

      return FileUploadResult(
        fileUri: fileId,
        // OpenAI file objects do not expose an explicit expiration in this flow.
        expirationTime: DateTime.now().add(const Duration(days: 3650)),
      );
    } on DioException catch (e) {
      throw _buildDioException(e, localizations);
    } catch (e) {
      throw Exception(localizations.networkErrorOpenAI);
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
    final apiKey = await configurationService.getOpenAIApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.openaiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;

    try {
      final data = <String, dynamic>{
        'model': selectedModel,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'file',
                'file': {'file_id': fileUri},
              },
            ],
          },
        ],
        'max_tokens': 8192,
        'temperature': 0.2,
      };

      if (responseMimeType == 'application/json') {
        data['response_format'] = {'type': 'json_object'};
      }

      final response = await dioClient.post(
        '$_baseUrl$_chatEndpoint',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: data,
      );

      final jsonResponse = response.data;
      final content = jsonResponse['choices'][0]['message']['content'];
      return content?.toString().trim() ?? localizations.noResponseReceived;
    } on DioException catch (e) {
      throw _buildDioException(e, localizations);
    } catch (e) {
      throw Exception(localizations.networkErrorOpenAI);
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
