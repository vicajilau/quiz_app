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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';

class AiFileUploadZone extends StatelessWidget {
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;
  final ValueChanged<bool> onAutoDifficultyChanged;
  final AiFileAttachment? fileAttachment;
  final bool isDragging;

  const AiFileUploadZone({
    super.key,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.onAutoDifficultyChanged,
    this.fileAttachment,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final attachStroke = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFD4D4D8);

    return GestureDetector(
      onTap: onPickFile,
      child: Container(
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDragging
              ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDragging ? Theme.of(context).primaryColor : attachStroke,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDragging ? LucideIcons.download : LucideIcons.paperclip,
                  color: isDragging
                      ? Theme.of(context).primaryColor
                      : colors.subtitle,
                  size: 20,
                ),
                const SizedBox(width: 12),
                if (isDragging)
                  Text(
                    localizations.dropAttachmentHere,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                else if (fileAttachment != null)
                  Text(
                    fileAttachment!.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.title,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    localizations.aiAttachFileHint,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.subtitle,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                if (fileAttachment != null && !isDragging)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        onRemoveFile();
                        onAutoDifficultyChanged(false);
                      },
                      child: Icon(LucideIcons.x, color: colors.title, size: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
