import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FileLoadedBottomBar extends StatelessWidget {
  final VoidCallback onAddQuestion;
  final VoidCallback onGenerateAI;
  final VoidCallback onImport;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final VoidCallback onPlay;
  final bool isPlayEnabled;
  final int selectedQuestionCount;
  final bool showSaveButton;

  const FileLoadedBottomBar({
    super.key,
    required this.onAddQuestion,
    required this.onGenerateAI,
    required this.onImport,
    required this.onSave,
    required this.onDelete,
    required this.onPlay,
    this.isPlayEnabled = false,
    this.selectedQuestionCount = 0,
    this.showSaveButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Add Button Colors
    final addBtnBg = isDark ? const Color(0xFF3F3F46) : Colors.white;
    final addBtnBorder = isDark
        ? const Color(0xFF52525B)
        : const Color(0xFFE4E4E7);
    final addBtnText = isDark ? Colors.white : const Color(0xFF18181B);
    final addBtnIcon = isDark ? Colors.white : const Color(0xFF18181B);

    // Secondary Button Colors (Import, Save)
    final secondaryBtnBg = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFE4E4E7);
    final secondaryBtnText = isDark ? Colors.white : const Color(0xFF18181B);
    final secondaryBtnIcon = isDark ? Colors.white : const Color(0xFF18181B);

    // Delete Button Colors
    final deleteBtnBg = isDark
        ? const Color(0xFF7F1D1D)
        : const Color(0xFFFEE2E2);
    final deleteBtnText = isDark
        ? const Color(0xFFFCA5A5)
        : const Color(0xFFDC2626);
    final deleteBtnIcon = isDark
        ? const Color(0xFFFCA5A5)
        : const Color(0xFFDC2626);

    return Container(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Action Buttons Row (Scrollable)
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        context,
                        icon: LucideIcons.plus,
                        label: AppLocalizations.of(context)!.addQuestion,
                        onPressed: onAddQuestion,
                        backgroundColor: addBtnBg,
                        borderColor: addBtnBorder,
                        textColor: addBtnText,
                        iconColor: addBtnIcon,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        context,
                        icon: LucideIcons.sparkles,
                        label: AppLocalizations.of(
                          context,
                        )!.generateQuestionsWithAI,
                        onPressed: onGenerateAI,
                        backgroundColor: const Color(0xFF14B8A6), // Teal 500
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        context,
                        icon: LucideIcons.upload,
                        label: AppLocalizations.of(context)!.importButton,
                        onPressed: onImport,
                        backgroundColor: secondaryBtnBg,
                        textColor: secondaryBtnText,
                        iconColor: secondaryBtnIcon,
                      ),
                      if (showSaveButton) ...[
                        const SizedBox(width: 12),
                        _buildActionButton(
                          context,
                          icon: LucideIcons.save,
                          label: AppLocalizations.of(context)!.saveButton,
                          onPressed: onSave,
                          backgroundColor: secondaryBtnBg,
                          textColor: secondaryBtnText,
                          iconColor: secondaryBtnIcon,
                        ),
                      ],
                      if (selectedQuestionCount > 0) ...[
                        const SizedBox(width: 12),
                        _buildActionButton(
                          context,
                          icon: LucideIcons.trash2,
                          label:
                              '${AppLocalizations.of(context)!.deleteButton} ($selectedQuestionCount)',
                          onPressed: onDelete,
                          backgroundColor: deleteBtnBg,
                          textColor: deleteBtnText, // Red 300 / Red 600
                          iconColor: deleteBtnIcon, // Red 300 / Red 600
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Start Quis Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isPlayEnabled ? onPlay : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6), // Violet 500
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFF8B5CF6,
                    ).withValues(alpha: 0.5),
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.play, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.startQuizButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    Color? borderColor,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 2)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
