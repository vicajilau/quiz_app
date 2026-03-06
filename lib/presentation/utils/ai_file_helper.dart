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

import 'package:flutter/foundation.dart';
import 'package:cross_file/cross_file.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';

class AiFileHelper {
  /// Attempts to load an [AiFileAttachment] from a saved file path.
  ///
  /// This uses `cross_file` `XFile`. Keep in mind that on Web, cross-session
  /// paths (like blob URLs) might become invalid and this will return null.
  static Future<AiFileAttachment?> loadAttachmentFromPath(String path) async {
    try {
      final xFile = XFile(path);
      final bytes = await xFile.readAsBytes();

      if (bytes.isEmpty) return null;

      final name = xFile.name;
      final mimeType =
          lookupMimeType(name, headerBytes: bytes) ??
          'application/octet-stream';

      return AiFileAttachment(
        bytes: bytes,
        mimeType: mimeType,
        name: name,
        path: path,
      );
    } catch (e) {
      // Ignore errors reading the file (e.g. file removed or expired blob URL on web).
      return null;
    }
  }

  /// Copies the attachment to a temporary directory so that it can be read
  /// reliably on next app launch.
  static Future<String?> saveAttachmentForDraft(
    AiFileAttachment attachment,
  ) async {
    if (kIsWeb) return attachment.path;

    try {
      final tempDir = await getTemporaryDirectory();
      final draftDirPath = '${tempDir.path}/ai_drafts';

      final xFile = XFile.fromData(attachment.bytes, name: attachment.name);

      // Enure trailing slash is removed from dir path
      final newPath =
          '$draftDirPath/${DateTime.now().millisecondsSinceEpoch}_${attachment.name}';

      await xFile.saveTo(newPath);
      return newPath;
    } catch (e) {
      return attachment.path;
    }
  }
}
