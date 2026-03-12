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

import 'package:flutter/material.dart';

import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/presentation/screens/dialogs/import_questions_dialog.dart';

/// Dialog to confirm importing chunks from another quiz file
class ImportChunksDialog extends StatelessWidget {
  final int chunkCount;
  final String fileName;

  const ImportChunksDialog({
    super.key,
    required this.chunkCount,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ImportPositionDialog(
      title: localizations.importChunksTitle,
      message: localizations.importChunksMessage(chunkCount, fileName),
      positionQuestion: localizations.importChunksPositionQuestion,
      importAtBeginning: localizations.importAtBeginning,
      importAtEnd: localizations.importAtEnd,
      cancelButton: localizations.cancelButton,
    );
  }
}
