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
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';

class StudyIndexChunkDownloadButton extends StatelessWidget {
  final bool isError;
  final VoidCallback? onDownload;
  final AppLocalizations localizations;

  const StudyIndexChunkDownloadButton({
    super.key,
    required this.isError,
    required this.onDownload,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isError
        ? (isDark ? AppTheme.zinc800 : AppTheme.zinc100)
        : AppTheme.primaryColor.withValues(alpha: 0.1);
    final fgColor = isError ? AppTheme.zinc500 : AppTheme.primaryColor;

    return GestureDetector(
      onTap: onDownload,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isError ? Icons.refresh : LucideIcons.sparkles,
              size: 15,
              color: fgColor,
            ),
            const SizedBox(width: 6),
            Text(
              isError
                  ? localizations.studyScreenRetry
                  : localizations.studyScreenDownloadChunk,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
