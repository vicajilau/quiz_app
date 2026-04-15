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
import 'package:quizdy/core/theme/extensions/custom_colors.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';

class StudyIndexHeroCard extends StatelessWidget {
  final StudyExecutionState state;
  final AppLocalizations localizations;

  const StudyIndexHeroCard({
    super.key,
    required this.state,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final summaryColor = isDark ? AppTheme.zinc400 : AppTheme.zinc500;
    final statCardBg = isDark ? const Color(0xFF1F1F23) : AppTheme.zinc100;
    final statLabelColor = isDark ? AppTheme.zinc500 : AppTheme.zinc400;
    final completedValueColor = isDark
        ? const Color(0xFF5EEAD4)
        : AppTheme.secondaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.studyScreenStudyGuide.toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            state.documentTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ),
        if (state.documentSummary != null &&
            state.documentSummary!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            state.documentSummary!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: summaryColor,
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 24),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatCard(
                context,
                value: '${state.chunks.length}',
                label: localizations.studyScreenSections,
                cardBg: statCardBg,
                labelColor: statLabelColor,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                context,
                value: '${state.progressPercentage.toStringAsFixed(0)}%',
                label: localizations.studyScreenCoverage,
                valueColor: AppTheme.primaryColor,
                cardBg: statCardBg,
                labelColor: statLabelColor,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                context,
                value: '${state.completedChunks}/${state.chunks.length}',
                label: localizations.studyScreenCompleted,
                valueColor: completedValueColor,
                cardBg: statCardBg,
                labelColor: statLabelColor,
              ),
            ],
          ),
        ),
        if (state.chunks.any(
          (c) =>
              c.status != StudyChunkState.completed &&
              c.status != StudyChunkState.downloaded,
        )) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).extension<CustomColors>()!.warningContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.alertTriangle,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).extension<CustomColors>()!.onWarningContainer,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    localizations.studyScreenPendingSections,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).extension<CustomColors>()!.onWarningContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String value,
    required String label,
    Color? valueColor,
    required Color cardBg,
    required Color labelColor,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
