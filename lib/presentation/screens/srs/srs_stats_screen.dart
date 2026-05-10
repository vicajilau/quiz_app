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
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/data/repositories/srs/srs_repository.dart';
import 'package:quizdy/domain/models/srs/srs_metadata.dart';

class SrsStatsScreen extends StatefulWidget {
  const SrsStatsScreen({super.key});

  @override
  State<SrsStatsScreen> createState() => _SrsStatsScreenState();
}

class _SrsStatsScreenState extends State<SrsStatsScreen> {
  late SrsRepository _srsRepository;
  Map<String, List<SrsMetadata>> _groupedStats = {};

  @override
  void initState() {
    super.initState();
    _srsRepository = ServiceLocator.getIt<SrsRepository>();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _groupedStats = _srsRepository.getStatsGroupedByFile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.srsStatsTitle),
        actions: _groupedStats.isEmpty
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.restart_alt),
                  onPressed: () => _confirmResetAll(context),
                  tooltip: l10n.srsResetAllStatsTooltip,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () => _confirmDeleteAll(context),
                  tooltip: l10n.srsDeleteAllStatsTooltip,
                ),
              ],
      ),
      body: _groupedStats.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds);
                      },
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        size: 120,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.srsEmptyStateTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.srsEmptyStateSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      child: Text(l10n.startQuizButton),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _groupedStats.length,
              itemBuilder: (context, index) {
                final fileId = _groupedStats.keys.elementAt(index);
                final stats = _groupedStats[fileId]!;
                return _buildFileStatsCard(fileId, stats);
              },
            ),
    );
  }

  Widget _buildFileStatsCard(String fileId, List<SrsMetadata> stats) {
    return _SrsFileStatsCard(
      fileId: fileId,
      stats: stats,
      onReset: () => _confirmResetFile(context, fileId),
      onDelete: () => _confirmDeleteFile(context, fileId),
    );
  }

  void _confirmResetFile(BuildContext context, String fileId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.srsResetStatsTitle),
        content: Text(l10n.srsResetStatsContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton.toUpperCase()),
          ),
          TextButton(
            onPressed: () async {
              await _srsRepository.resetStatsForFile(fileId);
              if (context.mounted) {
                _loadStats();
                Navigator.pop(context);
              }
            },
            child: Text(
              l10n.srsResetAllStatsTooltip.split(' ')[0].toUpperCase(),
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFile(BuildContext context, String fileId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.srsDeleteStatsTitle),
        content: Text(l10n.srsDeleteStatsContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton.toUpperCase()),
          ),
          TextButton(
            onPressed: () async {
              await _srsRepository.deleteStatsForFile(fileId);
              if (context.mounted) {
                _loadStats();
                Navigator.pop(context);
              }
            },
            child: Text(
              l10n.deleteButton.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetAll(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.srsResetAllStatsDialogTitle),
        content: Text(l10n.srsResetAllStatsDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton.toUpperCase()),
          ),
          TextButton(
            onPressed: () async {
              await _srsRepository.resetAllStats();
              if (context.mounted) {
                _loadStats();
                Navigator.pop(context);
              }
            },
            child: Text(
              l10n.srsResetAllStatsTooltip.toUpperCase(),
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.srsDeleteAllStatsDialogTitle),
        content: Text(l10n.srsDeleteAllStatsDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton.toUpperCase()),
          ),
          TextButton(
            onPressed: () async {
              await _srsRepository.deleteAllStats();
              if (context.mounted) {
                _loadStats();
                Navigator.pop(context);
              }
            },
            child: Text(
              l10n.srsDeleteAllStatsTooltip.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _SrsFileStatsCard extends StatefulWidget {
  final String fileId;
  final List<SrsMetadata> stats;
  final VoidCallback onReset;
  final VoidCallback onDelete;

  const _SrsFileStatsCard({
    required this.fileId,
    required this.stats,
    required this.onReset,
    required this.onDelete,
  });

  @override
  State<_SrsFileStatsCard> createState() => _SrsFileStatsCardState();
}

class _SrsFileStatsCardState extends State<_SrsFileStatsCard> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    int dueCount = 0;
    int totalQuestions = widget.stats.length;
    int totalCorrect = 0;
    int totalIncorrect = 0;

    for (var stat in widget.stats) {
      if (stat.nextReviewDate.isBefore(now) ||
          stat.nextReviewDate.isAtSameMomentAs(now)) {
        dueCount++;
      }
      totalCorrect += stat.timesCorrect;
      totalIncorrect += stat.timesIncorrect;
    }

    double retentionRate = totalCorrect + totalIncorrect > 0
        ? (totalCorrect / (totalCorrect + totalIncorrect)) * 100
        : 0.0;

    String displayTitle = widget.fileId.split('/').last;
    if (displayTitle.isEmpty) displayTitle = widget.fileId;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _toggleExpand,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayTitle,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.restart_alt,
                          color: Colors.orange,
                        ),
                        onPressed: widget.onReset,
                        tooltip: l10n.srsResetFileStatsTooltip,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        onPressed: widget.onDelete,
                        tooltip: l10n.srsDeleteFileStatsTooltip,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatMetric(
                    l10n.srsQuestions,
                    totalQuestions.toString(),
                    Icons.format_list_numbered,
                    context,
                  ),
                  _buildStatMetric(
                    l10n.srsDueNow,
                    dueCount.toString(),
                    Icons.access_time,
                    context,
                    color: dueCount > 0 ? Colors.orange : Colors.green,
                  ),
                  _buildStatMetric(
                    l10n.srsRetention,
                    '${retentionRate.toStringAsFixed(1)}%',
                    Icons.analytics,
                    context,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: totalCorrect + totalIncorrect > 0
                    ? totalCorrect / (totalCorrect + totalIncorrect)
                    : 0,
                backgroundColor: Colors.red.shade200,
                color: Colors.green.shade600,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.srsIncorrect(totalIncorrect),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.srsCorrect(totalCorrect),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? _buildQuestionsList(l10n)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatMetric(
    String label,
    String value,
    IconData icon,
    BuildContext context, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuestionsList(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          l10n.srsIndividualQuestions,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.stats.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final stat = widget.stats[index];
            final questionTitle = stat.questionText.isNotEmpty
                ? stat.questionText
                : l10n.srsQuestionId(stat.questionIdentity);

            final isDue =
                stat.nextReviewDate.isBefore(DateTime.now()) ||
                stat.nextReviewDate.isAtSameMomentAs(DateTime.now());

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questionTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        Icons.check_circle_outline,
                        l10n.srsCorrect(stat.timesCorrect),
                        color: stat.timesCorrect > 0
                            ? Colors.green
                            : Colors.grey,
                      ),
                      _buildChip(
                        Icons.cancel_outlined,
                        l10n.srsIncorrect(stat.timesIncorrect),
                        color: stat.timesIncorrect > 0
                            ? Colors.red
                            : Colors.grey,
                      ),
                      _buildChip(
                        Icons.av_timer,
                        '${l10n.srsIntervalShort} ${stat.interval}d',
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: l10n.srsIntervalTooltip,
                      ),
                      _buildChip(
                        Icons.psychology,
                        '${l10n.srsEaseShort} ${stat.easeFactor.toStringAsFixed(2)}',
                        color: Colors.blue,
                        tooltip: l10n.srsEaseTooltip,
                      ),
                      _buildChip(
                        isDue ? Icons.warning_amber_rounded : Icons.event,
                        '${l10n.srsDueShort} ${stat.nextReviewDate.toLocal().toString().split(' ')[0]}',
                        color: isDue ? Colors.orange : Colors.grey,
                        tooltip: l10n.srsDueTooltip,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChip(
    IconData icon,
    String label, {
    required Color color,
    String? tooltip,
  }) {
    final chip = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: chip);
    }
    return chip;
  }
}
