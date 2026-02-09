import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:quiz_app/core/l10n/app_localizations.dart';

class AbandonQuizDialog extends StatelessWidget {
  const AbandonQuizDialog({super.key});

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
    final primaryColor = const Color(0xFF8B5CF6);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: 400,
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
                    AppLocalizations.of(context)!.abandonQuiz,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: controlBgColor,
                    fixedSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                  ),
                  icon: Icon(Icons.close, size: 20, color: subTextColor),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            Text(
              AppLocalizations.of(context)!.abandonQuizConfirmation,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: subTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            ElevatedButton(
              onPressed: () {
                context.pop(); // Close dialog
                context.pop(); // Exit screen
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
              child: Text(AppLocalizations.of(context)!.abandon),
            ),
          ],
        ),
      ),
    );
  }
}
