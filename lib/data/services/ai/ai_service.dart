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

/// @deprecated Use [AiFileUploadResult] from the domain layer.
typedef FileUploadResult = AiFileUploadResult;

/// Legacy service abstraction for AI providers.
///
/// New code should use [AiRepository] (via [AiRepositoryFactory]) instead.
/// This interface remains to support existing call-sites that rely on
/// service-level helpers such as [serviceName] and [availableModels].
abstract class AIService {
  /// Obtiene una respuesta del servicio de IA basado en el prompt proporcionado
  Future<String> getChatResponse(
    String prompt,
    AppLocalizations localizations, {
    String? model,
    String? responseMimeType,
  });

  /// Obtiene una respuesta del servicio de IA enviando un fichero adjunto inline (base64)
  Future<String> getChatResponseWithFile(
    String prompt,
    AppLocalizations localizations, {
    String? model,
    String? responseMimeType,
    required AiFileAttachment file,
  });

  /// Sube un archivo al servicio de IA y devuelve su URI y fecha de expiración
  Future<AiFileUploadResult> uploadFile(
    AiFileAttachment file,
    AppLocalizations localizations,
  );

  /// Obtiene una respuesta del servicio de IA referenciando un archivo ya subido por su URI
  Future<String> getChatResponseWithFileUri(
    String prompt,
    AppLocalizations localizations, {
    String? model,
    String? responseMimeType,
    required String fileUri,
    required String fileMimeType,
  });

  /// Verifica si el servicio está disponible (tiene API key configurada)
  Future<bool> isAvailable();

  /// Obtiene el nombre del servicio para mostrar en la UI
  String get serviceName;

  /// Obtiene el modelo por defecto del servicio
  String get defaultModel;

  /// Obtiene la lista de modelos disponibles para este servicio
  List<String> get availableModels;
}
