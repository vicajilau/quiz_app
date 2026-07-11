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
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/domain/models/srs/srs_metadata.dart';
import 'package:quizdy/presentation/screens/widgets/srs/srs_question_row.dart';
import 'package:quizdy/presentation/screens/widgets/srs/srs_stat_metric.dart';

class SrsFileStatsCard extends StatefulWidget {
  final String fileId;
  final List<SrsMetadata> stats;
  final VoidCallback onReset;
  final VoidCallback onDelete;

  const SrsFileStatsCard({
    super.key,
    required this.fileId,
    required this.stats,
    required this.onReset,
    required this.onDelete,
  });

  @override
  State<SrsFileStatsCard> createState() => _SrsFileStatsCardState();
}

class _SrsFileStatsCardState extends State<SrsFileStatsCard> {
  bool _isExpanded = false;
  bool _isHovered = false;
  late int _dueCount;
  late int _totalQuestions;
  late int _totalCorrect;
  late int _totalIncorrect;
  late double _retentionRate;
  late String _displayTitle;

  @override
  void initState() {
    super.initState();
    _computeMetrics();
  }

  @override
  void didUpdateWidget(SrsFileStatsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stats != widget.stats || oldWidget.fileId != widget.fileId) {
      _computeMetrics();
    }
  }

  void _computeMetrics() {
    final now = DateTime.now();
    int dueCount = 0;
    int totalCorrect = 0;
    int totalIncorrect = 0;

    for (final stat in widget.stats) {
      if (!stat.nextReviewDate.isAfter(now)) dueCount++;
      totalCorrect += stat.timesCorrect;
      totalIncorrect += stat.timesIncorrect;
    }

    _dueCount = dueCount;
    _totalQuestions = widget.stats.length;
    _totalCorrect = totalCorrect;
    _totalIncorrect = totalIncorrect;
    _retentionRate = totalCorrect + totalIncorrect > 0
        ? (totalCorrect / (totalCorrect + totalIncorrect)) * 100
        : 0.0;
    final title = widget.fileId.split('/').last;
    _displayTitle = title.isEmpty ? widget.fileId : title;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = context.isMobile;
    final subtitleColor = isDark ? AppTheme.zinc400 : AppTheme.zinc500;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardColorDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isDark
                ? Border.all(color: Colors.transparent)
                : Border.all(color: AppTheme.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _isExpanded
                            ? AppTheme.primaryColor
                            : (isDark ? AppTheme.zinc700 : AppTheme.zinc100),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.file_text,
                        size: 16,
                        color: _isExpanded ? Colors.white : subtitleColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayTitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.backgroundColor
                                  : AppTheme.zinc900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              _CompactStat(
                                icon: LucideIcons.list_ordered,
                                value: '$_totalQuestions',
                                color: subtitleColor,
                              ),
                              if (kDebugMode) ...[
                                const SizedBox(width: 12),
                                _CompactStat(
                                  icon: LucideIcons.timer,
                                  value: '$_dueCount',
                                  color: _dueCount > 0
                                      ? Colors.orange
                                      : subtitleColor,
                                ),
                              ],
                              const SizedBox(width: 12),
                              _CompactStat(
                                icon: LucideIcons.chart_bar,
                                value: '${_retentionRate.toStringAsFixed(1)}%',
                                color: _retentionRate >= 50
                                    ? Colors.green.shade600
                                    : Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: Durations.medium2,
                      curve: Curves.easeInOutCubic,
                      child: (_isHovered || isMobile)
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _CardIconButton(
                                  icon: LucideIcons.trash_2,
                                  color: theme.colorScheme.error,
                                  onPressed: widget.onDelete,
                                  tooltip: l10n.srsDeleteFileStatsTooltip,
                                ),
                                const SizedBox(width: 4),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    Icon(
                      _isExpanded
                          ? LucideIcons.chevron_up
                          : LucideIcons.chevron_down,
                      size: 18,
                      color: subtitleColor,
                    ),
                  ],
                ),

                // ── Expanded content ────────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? _ExpandedContent(
                          l10n: l10n,
                          isDark: isDark,
                          totalQuestions: _totalQuestions,
                          dueCount: _dueCount,
                          retentionRate: _retentionRate,
                          totalCorrect: _totalCorrect,
                          totalIncorrect: _totalIncorrect,
                          stats: widget.stats,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private helpers ──────────────────────────────────────────────────────────

class _CompactStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _CompactStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CardIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String? tooltip;

  const _CardIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: color),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final int totalQuestions;
  final int dueCount;
  final double retentionRate;
  final int totalCorrect;
  final int totalIncorrect;
  final List<SrsMetadata> stats;

  const _ExpandedContent({
    required this.l10n,
    required this.isDark,
    required this.totalQuestions,
    required this.dueCount,
    required this.retentionRate,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = isDark
        ? AppTheme.borderColorDark
        : AppTheme.borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Divider(height: 1, color: dividerColor),
        const SizedBox(height: 20),

        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SrsStatMetric(
              label: l10n.srsQuestions,
              value: totalQuestions.toString(),
              icon: LucideIcons.list_ordered,
              color: AppTheme.primaryColor,
            ),
            if (kDebugMode) ...[
              SrsStatMetric(
                label: l10n.srsDueNow,
                value: dueCount.toString(),
                icon: LucideIcons.timer,
                color: dueCount > 0 ? Colors.orange : Colors.green,
              ),
            ],
            SrsStatMetric(
              label: l10n.srsRetention,
              value: '${retentionRate.toStringAsFixed(1)}%',
              icon: LucideIcons.chart_bar,
              color: retentionRate >= 50 ? Colors.green.shade600 : Colors.red,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: totalCorrect + totalIncorrect > 0
                ? totalCorrect / (totalCorrect + totalIncorrect)
                : 0,
            backgroundColor: Theme.of(context).colorScheme.error,
            color: Colors.green.shade600,
            minHeight: 8,
          ),
        ),

        const SizedBox(height: 6),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.srsCorrect(totalCorrect),
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              l10n.srsIncorrect(totalIncorrect),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),

        // Individual questions
        const SizedBox(height: 16),
        Divider(height: 1, color: dividerColor),
        const SizedBox(height: 12),
        Text(
          l10n.srsIndividualQuestions,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.backgroundColor : AppTheme.zinc900,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          separatorBuilder: (_, _) => const SizedBox(height: 6),
          itemBuilder: (_, index) => SrsQuestionRow(stat: stats[index]),
        ),
      ],
    );
  }
}
