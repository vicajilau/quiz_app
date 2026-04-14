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

import 'package:flutter/foundation.dart';
import 'package:llamadart/llamadart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_file_upload_result.dart';
import 'package:quizdy/domain/models/ai/ai_model_catalog.dart';
import 'package:quizdy/domain/repositories/ai_repository.dart';

/// Local llama.cpp implementation of [AiRepository] via the llamadart package.
///
/// Runs inference entirely on-device using a GGUF model file stored locally.
/// No network calls are made.
///
/// [sendMessages] is fully supported.  File-based methods support plain-text
/// attachments (text/*); binary formats such as PDF are not supported and will
/// throw [UnsupportedError].
///
/// Not available on Web — [isAvailable] always returns `false` there.
class LocalLlamaRepository implements AiRepository {
  final ConfigurationService _configurationService;

  @override
  final String modelId;

  LocalLlamaRepository({
    required ConfigurationService configurationService,
    required this.modelId,
  }) : _configurationService = configurationService;

  @override
  String get providerId => AiModelCatalog.llamaProviderId;

  // ── Availability ──────────────────────────────────────────────────────────

  @override
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    final path = await _configurationService.getLocalModelPath();
    if (path == null || path.isEmpty) return false;
    return File(path).existsSync();
  }

  // ── Core inference ────────────────────────────────────────────────────────

  /// Runs a full completion for [prompt] on the locally configured GGUF model.
  ///
  /// Creates and disposes a [LlamaEngine] per call, which keeps memory clean
  /// at the cost of model-load latency (~1-5 s). For high-frequency use, a
  /// persistent engine with context reuse would be more efficient.
  @override
  Future<String> sendMessages(
    String prompt,
    AppLocalizations localizations, {
    String? responseMimeType,
  }) async {
    final modelPath = await _resolveModelPath(localizations);
    // ignore: avoid_print
    print('[LocalLlama] loading model: $modelPath');
    LlamaEngine.configureLogging(level: LlamaLogLevel.info);
    final engine = LlamaEngine(LlamaBackend());
    try {
      await engine.loadModel(modelPath);
      // ignore: avoid_print
      print('[LocalLlama] model loaded — starting inference');
      final session = ChatSession(engine);

      final buffer = StringBuffer();
      await for (final chunk in session.create([
        LlamaTextContent(prompt),
      ], enableThinking: false)) {
        final token = chunk.choices.firstOrNull?.delta.content;
        if (token != null) {
          // ignore: avoid_print
          print('[LocalLlama] token: $token');
          buffer.write(token);
        }
      }
      // ignore: avoid_print
      print('[LocalLlama] inference complete');
      final result = buffer.toString().replaceAll('\n', ' ').trim();
      return result.isEmpty ? localizations.noResponseReceived : result;
    } catch (e, st) {
      // ignore: avoid_print
      print('[LocalLlama] inference error: $e\n$st');
      throw Exception('LocalLlama: $e');
    } finally {
      await engine.dispose();
    }
  }

  // ── File-based methods ────────────────────────────────────────────────────

  /// Inlines the text content of the file into the prompt.
  ///
  /// Only text/* MIME types are supported. Binary formats (PDF, images, etc.)
  /// throw [UnsupportedError].
  @override
  Future<String> sendMessagesWithFile(
    String prompt,
    AppLocalizations localizations, {
    required AiFileAttachment file,
    String? responseMimeType,
  }) async {
    final fileText = utf8.decode(file.bytes, allowMalformed: true);
    return sendMessages(
      '$prompt\n\n$fileText',
      localizations,
      responseMimeType: responseMimeType,
    );
  }

  /// Saves the attachment bytes to the app's temp directory.
  ///
  /// Returns the local file path as the URI — no network upload occurs.
  @override
  Future<AiFileUploadResult> uploadFile(
    AiFileAttachment file,
    AppLocalizations localizations,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final dest = File('${tempDir.path}/${file.name}');
    await dest.writeAsBytes(file.bytes);
    return AiFileUploadResult(
      fileUri: dest.path,
      // Local files do not expire; sentinel far-future date.
      expirationTime: DateTime(9999),
    );
  }

  /// Reads the file from the local path URI and inlines its text content.
  ///
  /// Only text/* MIME types are supported.
  @override
  Future<String> sendMessagesWithFileUri(
    String prompt,
    AppLocalizations localizations, {
    required String fileUri,
    required String fileMimeType,
    String? responseMimeType,
  }) async {
    final fileText = await File(fileUri).readAsString();
    return sendMessages(
      '$prompt\n\n$fileText',
      localizations,
      responseMimeType: responseMimeType,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<String> _resolveModelPath(AppLocalizations localizations) async {
    final path = await _configurationService.getLocalModelPath();
    if (path == null || path.isEmpty || !File(path).existsSync()) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }
    return path;
  }
}
