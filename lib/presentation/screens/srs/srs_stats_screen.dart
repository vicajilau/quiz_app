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
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/core/theme/extensions/quiz_loaded_theme.dart';
import 'package:quizdy/data/repositories/srs/srs_repository.dart';
import 'package:quizdy/domain/models/srs/srs_metadata.dart';
import 'package:quizdy/presentation/screens/widgets/common/quizdy_app_bar.dart';
import 'package:quizdy/presentation/screens/widgets/srs/srs_empty_state.dart';
import 'package:quizdy/presentation/screens/widgets/srs/srs_file_stats_card.dart';

enum _SrsSortField { sectionOrder, name, pendingQuestions, hitRate }

enum _SrsSortDirection { ascending, descending }

class SrsStatsScreen extends StatefulWidget {
  const SrsStatsScreen({super.key});

  @override
  State<SrsStatsScreen> createState() => _SrsStatsScreenState();
}

class _SrsStatsScreenState extends State<SrsStatsScreen> {
  late SrsRepository _srsRepository;
  Map<String, List<SrsMetadata>> _groupedStats = {};
  _SrsSortField _sortField = _SrsSortField.sectionOrder;
  _SrsSortDirection _sortDirection = _SrsSortDirection.ascending;

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

  /// Returns [stats] sorted according to the current [_sortField] and
  /// [_sortDirection]. A copy is always returned to avoid mutating the cache.
  List<SrsMetadata> _sortedStats(List<SrsMetadata> stats) {
    if (_sortField == _SrsSortField.sectionOrder) return List.of(stats);

    final sorted = List.of(stats);
    sorted.sort((a, b) {
      final int comparison;
      switch (_sortField) {
        case _SrsSortField.sectionOrder:
          comparison = 0;
        case _SrsSortField.name:
          comparison = a.questionText.toLowerCase().compareTo(
            b.questionText.toLowerCase(),
          );
        case _SrsSortField.pendingQuestions:
          // Earlier nextReviewDate → more urgent → comes first in ascending.
          comparison = a.nextReviewDate.compareTo(b.nextReviewDate);
        case _SrsSortField.hitRate:
          comparison = _retentionRate(a).compareTo(_retentionRate(b));
      }
      return _sortDirection == _SrsSortDirection.ascending
          ? comparison
          : -comparison;
    });
    return sorted;
  }

  double _retentionRate(SrsMetadata s) {
    final total = s.timesCorrect + s.timesIncorrect;
    return total > 0 ? s.timesCorrect / total * 100 : 0.0;
  }

  void _onSortFieldSelected(_SrsSortField field) {
    setState(() {
      if (_sortField == field) {
        _sortDirection = _sortDirection == _SrsSortDirection.ascending
            ? _SrsSortDirection.descending
            : _SrsSortDirection.ascending;
      } else {
        _sortField = field;
        _sortDirection = _SrsSortDirection.ascending;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: QuizdyAppBar(
        title: Text(
          l10n.srsStatsTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        onLeadingPressed: () => context.pop(),
        actions: _groupedStats.isEmpty
            ? null
            : [
                _SortMenuButton(
                  sortField: _sortField,
                  sortDirection: _sortDirection,
                  onSelected: _onSortFieldSelected,
                ),
                _AppBarActionButton(
                  icon: Icons.restart_alt,
                  tooltip: l10n.srsResetAllStatsTooltip,
                  onPressed: () => _confirmDeleteAll(context),
                ),
              ],
      ),
      body: _groupedStats.isEmpty
          ? const SrsEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _groupedStats.length,
              itemBuilder: (context, index) {
                final fileId = _groupedStats.keys.elementAt(index);
                final stats = _sortedStats(_groupedStats[fileId]!);
                return SrsFileStatsCard(
                  key: ValueKey(fileId),
                  fileId: fileId,
                  stats: stats,
                  onReset: () => _confirmResetFile(context, fileId),
                  onDelete: () => _confirmDeleteFile(context, fileId),
                );
              },
            ),
    );
  }

  void _confirmResetFile(BuildContext context, String fileId) {
    final l10n = AppLocalizations.of(context)!;
    _showConfirmDialog(
      context: context,
      title: l10n.srsResetStatsTitle,
      content: l10n.srsResetStatsContent,
      confirmLabel: l10n.srsResetButton,
      onConfirm: () => _srsRepository.resetStatsForFile(fileId),
    );
  }

  void _confirmDeleteFile(BuildContext context, String fileId) {
    final l10n = AppLocalizations.of(context)!;
    _showConfirmDialog(
      context: context,
      title: l10n.srsDeleteStatsTitle,
      content: l10n.srsDeleteStatsContent,
      confirmLabel: l10n.deleteButton,
      onConfirm: () => _srsRepository.deleteStatsForFile(fileId),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _showConfirmDialog(
      context: context,
      title: l10n.srsDeleteAllStatsDialogTitle,
      content: l10n.srsDeleteAllStatsDialogContent,
      confirmLabel: l10n.srsDeleteAllStatsTooltip,
      onConfirm: _srsRepository.deleteAllStats,
    );
  }

  void _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmLabel,
    required Future<void> Function() onConfirm,
  }) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => context.pop(ctx),
            child: Text(l10n.cancelButton.toUpperCase()),
          ),
          TextButton(
            onPressed: () async {
              await onConfirm();
              if (ctx.mounted) {
                _loadStats();
                context.pop(ctx);
              }
            },
            child: Text(confirmLabel.toUpperCase()),
          ),
        ],
      ),
    );
  }
}

// ── AppBar widgets ────────────────────────────────────────────────────────────

class _AppBarActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _AppBarActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: context.quizLoadedTheme.appBarIconBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 20,
        ),
        tooltip: tooltip,
      ),
    );
  }
}

class _SortMenuButton extends StatelessWidget {
  final _SrsSortField sortField;
  final _SrsSortDirection sortDirection;
  final ValueChanged<_SrsSortField> onSelected;

  const _SortMenuButton({
    required this.sortField,
    required this.sortDirection,
    required this.onSelected,
  });

  IconData get _directionIcon => sortDirection == _SrsSortDirection.ascending
      ? LucideIcons.arrowUp
      : LucideIcons.arrowDown;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    final fields = [
      (_SrsSortField.sectionOrder, l10n.srsSortBySectionOrder),
      (_SrsSortField.name, l10n.srsSortByName),
      (_SrsSortField.pendingQuestions, l10n.srsSortByPendingQuestions),
      (_SrsSortField.hitRate, l10n.srsSortByHitRate),
    ];

    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: context.quizLoadedTheme.appBarIconBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: PopupMenuButton<_SrsSortField>(
        padding: EdgeInsets.zero,
        tooltip: l10n.srsSortTooltip,
        icon: Icon(LucideIcons.arrowUpDown, color: onPrimary, size: 20),
        onSelected: onSelected,
        itemBuilder: (context) => fields.map((entry) {
          final (field, label) = entry;
          final isSelected = sortField == field;
          return PopupMenuItem<_SrsSortField>(
            value: field,
            child: Row(
              children: [
                Icon(
                  isSelected ? _directionIcon : LucideIcons.minus,
                  size: 16,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
