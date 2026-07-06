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
import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_file_upload_result.dart';
import 'package:quizdy/domain/models/ai/ai_model_catalog.dart';
import 'package:quizdy/domain/models/custom_exceptions/connectivity_exception.dart';
import 'package:quizdy/domain/repositories/ai_repository.dart';

/// Gemini implementation of [AiRepository].
///
/// Handles the Gemini wire format, authentication, rate-limit errors, and
/// file uploads via the Gemini File API.  Contains no prompt text.
class GeminiRepository implements AiRepository {
  static const String _uploadBaseUrlBeta =
      'https://generativelanguage.googleapis.com/upload/v1beta';

  final Dio _dioClient;
  final ConfigurationService _configurationService;

  @override
  final String modelId;

  GeminiRepository({
    required this._dioClient,
    required this._configurationService,
    required this.modelId,
  });

  @override
  String get providerId => AiModelCatalog.geminiProviderId;

  @override
  Future<bool> isAvailable() async {
    final key = await _configurationService.getGeminiApiKey();
    return key != null && key.isNotEmpty;
  }

  // ── Error helpers ────────────────────────────────────────────────────────

  String _extractErrorDetail(DioException e, AppLocalizations localizations) {
    final data = e.response?.data;
    if (data != null &&
        data['error'] != null &&
        data['error']['message'] != null) {
      return '${localizations.aiErrorResponse} ${data['error']['message']}';
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == null) return localizations.aiErrorResponse;
    return '${localizations.aiErrorResponse} ($statusCode)';
  }

  Exception _buildException(DioException e, AppLocalizations localizations) {
    if (e.error is ConnectivityException) {
      final ce = e.error as ConnectivityException;
      return Exception(
        ce.type == ConnectivityExceptionType.connectionAborted
            ? localizations.aiErrorConnectionAborted
            : localizations.noInternetConnection,
      );
    }
    return switch (e.response?.statusCode) {
      302 => Exception(
        localizations.aiErrorRedirect(
          e.response?.headers['location']?.first ?? '',
        ),
      ),
      400 => Exception(_extractErrorDetail(e, localizations)),
      403 => Exception(localizations.invalidApiKeyError),
      429 => Exception(localizations.rateLimitError),
      _ => Exception(_extractErrorDetail(e, localizations)),
    };
  }

  // ── AiRepository interface ───────────────────────────────────────────────

  @override
  Future<String> sendMessages(
    String prompt,
    AppLocalizations localizations, {
    String? responseMimeType,
  }) async {
    final apiKey = await _configurationService.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final ai = Genkit(plugins: [googleAI(apiKey: apiKey)]);

    try {
      final response = await ai.generate(
        model: googleAI.gemini(modelId),
        prompt: prompt,
        config: GeminiOptions(
          temperature: 0.2,
          topK: 5,
          topP: 0.95,
          responseMimeType: responseMimeType,
          safetySettings: [
            SafetySettings(
              category: 'HARM_CATEGORY_HARASSMENT',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE',
            ),
            SafetySettings(
              category: 'HARM_CATEGORY_HATE_SPEECH',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE',
            ),
            SafetySettings(
              category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE',
            ),
            SafetySettings(
              category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE',
            ),
          ],
        ),
      );
      return response.text;
    } catch (e) {
      throw Exception('${localizations.networkErrorGemini}: $e');
    }
  }

  @override
  Future<String> sendMessagesWithFile(
    String prompt,
    AppLocalizations localizations, {
    required AiFileAttachment file,
    String? responseMimeType,
  }) async {
    final apiKey = await _configurationService.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final ai = Genkit(plugins: [googleAI(apiKey: apiKey)]);
    final base64Data = base64Encode(file.bytes);
    final dataUrl = 'data:${file.mimeType};base64,$base64Data';

    try {
      final response = await ai.generate(
        model: googleAI.gemini(modelId),
        messages: [
          Message(
            role: Role.user,
            content: [
              MediaPart(
                media: Media(contentType: file.mimeType, url: dataUrl),
              ),
              TextPart(text: prompt),
            ],
          ),
        ],
        config: GeminiOptions(
          temperature: 0.2,
          topK: 5,
          topP: 0.95,
          responseMimeType: responseMimeType,
          safetySettings: [
            SafetySettings(
              category: 'HARM_CATEGORY_HARASSMENT',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE',
            ),
            SafetySettings(
              category: 'HARM_CATEGORY_HATE_SPEECH',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE',
            ),
            SafetySettings(
              category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE',
            ),
            SafetySettings(
              category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE',
            ),
          ],
        ),
      );
      return response.text;
    } catch (e) {
      throw Exception('${localizations.networkErrorGemini}: $e');
    }
  }

  @override
  Future<AiFileUploadResult> uploadFile(
    AiFileAttachment file,
    AppLocalizations localizations,
  ) async {
    final apiKey = await _configurationService.getGeminiApiKey();
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

      final response = await _dioClient.post(
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

      final fileUri = response.data['file']?['uri'] as String?;
      final expirationTimeStr =
          response.data['file']?['expirationTime'] as String?;

      if (fileUri != null && expirationTimeStr != null) {
        return AiFileUploadResult(
          fileUri: fileUri,
          expirationTime: DateTime.parse(expirationTimeStr),
        );
      }
      throw Exception(localizations.noResponseReceived);
    } on DioException catch (e) {
      throw _buildException(e, localizations);
    } catch (_) {
      throw Exception(localizations.networkErrorGemini);
    }
  }

  @override
  Future<String> sendMessagesWithFileUri(
    String prompt,
    AppLocalizations localizations, {
    required String fileUri,
    required String fileMimeType,
    String? responseMimeType,
  }) async {
    final apiKey = await _configurationService.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final ai = Genkit(plugins: [googleAI(apiKey: apiKey)]);

    try {
      final response = await ai.generate(
        model: googleAI.gemini(modelId),
        messages: [
          Message(
            role: Role.user,
            content: [
              MediaPart(
                media: Media(contentType: fileMimeType, url: fileUri),
              ),
              TextPart(text: prompt),
            ],
          ),
        ],
        config: GeminiOptions(
          temperature: 0.2,
          topK: 5,
          topP: 0.95,
          responseMimeType: responseMimeType,
          safetySettings: [
            SafetySettings(
              category: 'HARM_CATEGORY_HARASSMENT',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE',
            ),
            SafetySettings(
              category: 'HARM_CATEGORY_HATE_SPEECH',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE',
            ),
            SafetySettings(
              category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE',
            ),
            SafetySettings(
              category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
              threshold: 'BLOCK_MEDIUM_AND_ABOVE',
            ),
          ],
        ),
      );
      return response.text;
    } catch (e) {
      throw Exception('${localizations.networkErrorGemini}: $e');
    }
  }
}
