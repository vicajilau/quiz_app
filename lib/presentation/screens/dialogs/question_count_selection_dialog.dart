import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/data/services/configuration_service.dart';
import 'package:quiz_app/domain/models/quiz/quiz_config.dart';
import 'package:quiz_app/domain/models/quiz/quiz_config_stored_settings.dart';

class QuestionCountSelectionDialog extends StatefulWidget {
  final int totalQuestions;

  const QuestionCountSelectionDialog({super.key, required this.totalQuestions});

  @override
  State<QuestionCountSelectionDialog> createState() =>
      _QuestionCountSelectionDialogState();
}

class _QuestionCountSelectionDialogState
    extends State<QuestionCountSelectionDialog> {
  int _selectedCount = 10;
  bool _isStudyMode = false; // false = Exam, true = Study

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final settings = await ConfigurationService.instance
        .getQuizConfigSettings();
    if (mounted) {
      setState(() {
        if (settings.questionCount != null) {
          _selectedCount = settings.questionCount!.clamp(
            1,
            widget.totalQuestions,
          );
        } else {
          _selectedCount = widget.totalQuestions;
        }

        if (settings.isStudyMode != null) {
          _isStudyMode = settings.isStudyMode!;
        }
      });
    }
  }

  void _incrementCount() {
    setState(() {
      if (_selectedCount < widget.totalQuestions) {
        _selectedCount++;
      }
    });
  }

  void _decrementCount() {
    setState(() {
      if (_selectedCount > 1) {
        _selectedCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF18181B);
    final subTextColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);
    final borderColor = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFE4E4E7);
    final controlBgColor = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFF4F4F5);
    final controlIconColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF3F3F46);
    final primaryColor = const Color(0xFF8B5CF6);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: 520, // Max width from design
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardColor,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.startQuiz,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => context.pop(null),
                  style: IconButton.styleFrom(
                    backgroundColor: controlBgColor,
                    fixedSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                  ),
                  icon: Icon(LucideIcons.x, size: 20, color: subTextColor),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Question Count
            Text(
              // Using existing key, but strictly "Number of Questions" in design
              // If localization key text differs, user might notice, but functionally mostly same.
              // Design says "Number of Questions".
              AppLocalizations.of(context)!.numberInputLabel,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Minus Button
                _buildCountControl(
                  icon: LucideIcons.minus,
                  onTap: _decrementCount,
                  bgColor: controlBgColor,
                  iconColor: controlIconColor,
                ),
                const SizedBox(width: 16),
                // Display
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: controlBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _selectedCount.toString(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Plus Button
                _buildCountControl(
                  icon: LucideIcons.plus,
                  onTap: _incrementCount,
                  bgColor: primaryColor,
                  iconColor: Colors.white,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Quiz Mode
            Text(
              AppLocalizations.of(context)!.quizModeTitle,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 12),

            // Mode Options (Horizontal Row)
            Row(
              children: [
                Expanded(
                  child: _buildModeOption(
                    context: context,
                    title: AppLocalizations.of(context)!.examModeLabel,
                    icon: LucideIcons.fileText,
                    isSelected: !_isStudyMode,
                    onTap: () => setState(() => _isStudyMode = false),
                    primaryColor: primaryColor,
                    defaultBgColor: controlBgColor,
                    defaultTextColor: subTextColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModeOption(
                    context: context,
                    title: AppLocalizations.of(context)!.studyModeLabel,
                    icon: LucideIcons.bookOpen,
                    isSelected: _isStudyMode,
                    onTap: () => setState(() => _isStudyMode = true),
                    primaryColor: primaryColor,
                    defaultBgColor: controlBgColor,
                    defaultTextColor: subTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Mode Description
            Text(
              _isStudyMode
                  ? AppLocalizations.of(context)!.studyModeDescription
                  : AppLocalizations.of(context)!.examModeDescription,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: subTextColor,
                height: 1.4,
              ),
              textAlign: TextAlign.start,
            ),

            const SizedBox(height: 32),

            // Start Button
            ElevatedButton(
              onPressed: () {
                ConfigurationService.instance.saveQuizConfigSettings(
                  QuizConfigStoredSettings(
                    questionCount: _selectedCount,
                    isStudyMode: _isStudyMode,
                  ),
                );

                context.pop(
                  QuizConfig(
                    questionCount: _selectedCount,
                    isStudyMode: _isStudyMode,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.play, size: 20),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.startQuiz),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountControl({
    required IconData icon,
    required VoidCallback onTap,
    required Color bgColor,
    required Color iconColor,
  }) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: iconColor,
        fixedSize: const Size(48, 48),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 20),
    );
  }

  Widget _buildModeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color defaultBgColor,
    required Color defaultTextColor,
  }) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: isSelected ? primaryColor : defaultBgColor,
        foregroundColor: isSelected ? Colors.white : defaultTextColor,
        minimumSize: const Size(double.infinity, 64),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : defaultTextColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : defaultTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
