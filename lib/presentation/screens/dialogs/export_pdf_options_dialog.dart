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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:quizdy/presentation/widgets/quizdy_switch.dart';

/// Options returned by [ExportPdfOptionsDialog].
class PdfExportOptions {
  final bool includeStudy;
  final bool includeQuestions;
  final bool includeAnswers;

  const PdfExportOptions({
    this.includeStudy = true,
    required this.includeQuestions,
    required this.includeAnswers,
  });
}

/// Dialog that lets the user configure PDF export options before exporting.
///
/// When [hasStudy] is `true`, a toggle to include the study content is shown
/// at the top. When [hasQuestions] is `true`, toggles for a questions page
/// and optional correct answers are shown below.
/// Returns a [PdfExportOptions] if the user confirms, or `null` if cancelled.
class ExportPdfOptionsDialog extends StatefulWidget {
  /// Whether there is study content available to include.
  final bool hasStudy;

  /// Whether the quiz file has questions available to include.
  final bool hasQuestions;

  const ExportPdfOptionsDialog({
    super.key,
    required this.hasStudy,
    required this.hasQuestions,
  });

  @override
  State<ExportPdfOptionsDialog> createState() => _ExportPdfOptionsDialogState();
}

class _ExportPdfOptionsDialogState extends State<ExportPdfOptionsDialog> {
  bool _includeStudy = true;
  bool _includeQuestions = false;
  bool _includeAnswers = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final borderColor = isDark ? Colors.transparent : AppTheme.borderColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      localizations.exportPdfOptionsTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.title,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        LucideIcons.x,
                        color: colors.subtitle,
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surface,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Study toggle
            if (widget.hasStudy)
              _ExportOptionRow(
                title: localizations.exportPdfOptionsIncludeStudy,
                subtitle: localizations.exportPdfOptionsIncludeStudySubtitle,
                value: _includeStudy,
                onChanged: (value) => setState(() => _includeStudy = value),
                colors: colors,
              ),

            // Questions / answers toggles
            if (widget.hasQuestions) ...[
              _ExportOptionRow(
                title: localizations.exportPdfOptionsIncludeQuestions,
                subtitle:
                    localizations.exportPdfOptionsIncludeQuestionsSubtitle,
                value: _includeQuestions,
                onChanged: (value) => setState(() {
                  _includeQuestions = value;
                  if (!value) _includeAnswers = false;
                }),
                colors: colors,
              ),
              if (_includeQuestions)
                _ExportOptionRow(
                  title: localizations.exportPdfOptionsIncludeAnswers,
                  subtitle:
                      localizations.exportPdfOptionsIncludeAnswersSubtitle,
                  value: _includeAnswers,
                  onChanged: (value) => setState(() => _includeAnswers = value),
                  colors: colors,
                ),
            ],

            if (widget.hasStudy || widget.hasQuestions)
              const SizedBox(height: 8),

            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(height: 1, thickness: 1, color: colors.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: QuizdyButton(
                          expanded: true,
                          type: QuizdyButtonType.primary,
                          title: localizations.exportButton,
                          onPressed: () => context.pop(
                            PdfExportOptions(
                              includeStudy: _includeStudy,
                              includeQuestions: _includeQuestions,
                              includeAnswers: _includeAnswers,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportOptionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ConfirmingDialogColorsExtension colors;

  const _ExportOptionRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.title,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: colors.subtitle),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          QuizdySwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
