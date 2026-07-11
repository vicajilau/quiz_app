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
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/domain/models/srs/srs_metadata.dart';
import 'package:quizdy/presentation/widgets/quizdy_latex_text.dart';

class SrsQuestionRow extends StatelessWidget {
  final SrsMetadata stat;

  const SrsQuestionRow({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppTheme.zinc400 : AppTheme.zinc500;
    final isDue = !stat.nextReviewDate.isAfter(DateTime.now());
    final dueDate = stat.nextReviewDate.toLocal().toString().split(' ')[0];
    final questionTitle = stat.questionText.isNotEmpty
        ? stat.questionText
        : l10n.srsQuestionId(stat.questionIdentity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.zinc700 : AppTheme.zinc100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuizdyLatexText(
            questionTitle,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isDark ? AppTheme.backgroundColor : AppTheme.zinc900,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(LucideIcons.tag, size: 11, color: subtitleColor),
              const SizedBox(width: 4),
              Text(
                stat.sectionName ?? l10n.srsUnassignedSection,
                style: TextStyle(
                  fontSize: 11,
                  color: subtitleColor,
                  fontStyle: stat.sectionName == null
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _SrsChip(
                icon: LucideIcons.check,
                label: l10n.srsCorrect(stat.timesCorrect),
                color: stat.timesCorrect > 0
                    ? Colors.green.shade700
                    : subtitleColor,
              ),
              _SrsChip(
                icon: LucideIcons.x,
                label: l10n.srsIncorrect(stat.timesIncorrect),
                color: stat.timesIncorrect > 0 ? Colors.red : subtitleColor,
              ),

              if (kDebugMode) ...[
                _SrsChip(
                  icon: isDue
                      ? LucideIcons.triangle_alert
                      : LucideIcons.calendar_days,
                  label: '${l10n.srsDueShort} $dueDate',
                  color: isDue ? Colors.orange : subtitleColor,
                  tooltip: l10n.srsDueTooltip,
                ),
                _SrsChip(
                  icon: LucideIcons.timer,
                  label: '${l10n.srsIntervalShort} ${stat.interval}d',
                  color: subtitleColor,
                  tooltip: l10n.srsIntervalTooltip,
                ),
                _SrsChip(
                  icon: LucideIcons.brain,
                  label:
                      '${l10n.srsEaseShort} ${stat.easeFactor.toStringAsFixed(2)}',
                  color: Colors.blue,
                  tooltip: l10n.srsEaseTooltip,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SrsChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? tooltip;

  const _SrsChip({
    required this.icon,
    required this.label,
    required this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final chip = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    return tooltip != null ? Tooltip(message: tooltip!, child: chip) : chip;
  }
}
