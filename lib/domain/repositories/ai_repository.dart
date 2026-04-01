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

import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_file_upload_result.dart';

/// Pure execution contract for AI providers.
///
/// Implementations act only as an execution engine: they receive
/// pre-assembled message payloads and handle provider-specific wire
/// format, rate limits, and errors.  No prompt text is built here.
abstract class AiRepository {
  /// Provider identifier, e.g. `'openai'` or `'gemini'`.
  String get providerId;

  /// Model identifier this instance is configured for,
  /// e.g. `'gpt-4o-mini'` or `'gemini-2.5-flash'`.
  String get modelId;

  /// Returns `true` if the provider's API key is configured.
  Future<bool> isAvailable();

  /// Sends a plain-text prompt and returns the provider's text response.
  Future<String> sendMessages(
    String prompt,
    AppLocalizations localizations, {
    String? responseMimeType,
  });

  /// Sends a prompt together with a file attachment (inline bytes).
  Future<String> sendMessagesWithFile(
    String prompt,
    AppLocalizations localizations, {
    required AiFileAttachment file,
    String? responseMimeType,
  });

  /// Uploads a file to the provider and returns its remote URI.
  Future<AiFileUploadResult> uploadFile(
    AiFileAttachment file,
    AppLocalizations localizations,
  );

  /// Sends a prompt that references a previously uploaded file by URI.
  Future<String> sendMessagesWithFileUri(
    String prompt,
    AppLocalizations localizations, {
    required String fileUri,
    required String fileMimeType,
    String? responseMimeType,
  });
}
