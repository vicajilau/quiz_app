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
import 'package:go_router/go_router.dart';

import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/presentation/screens/dialogs/import_questions_dialog.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

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

    return AlertDialog(
      title: Text(localizations.importChunksTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.importChunksMessage(chunkCount, fileName),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.importChunksPositionQuestion,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        QuizdyButton(
          type: QuizdyButtonType.tertiary,
          title: localizations.cancelButton,
          onPressed: () => context.pop(null),
        ),
        QuizdyButton(
          title: localizations.importAtBeginning,
          onPressed: () => context.pop(QuestionsPosition.beginning),
        ),
        QuizdyButton(
          title: localizations.importAtEnd,
          onPressed: () => context.pop(QuestionsPosition.end),
        ),
      ],
    );
  }
}
