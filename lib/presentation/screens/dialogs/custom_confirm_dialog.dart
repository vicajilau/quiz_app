import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final VoidCallback? onConfirm;
  final bool isDestructive;

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.onConfirm,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Design Tokens matching AIQuestionDialog style
    final backgroundColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final borderColor = isDark ? Colors.transparent : const Color(0xFFE4E4E7);
    final closeBtnColor = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFF4F4F5);
    final closeIconColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);
    final titleColor = isDark ? Colors.white : const Color(0xFF18181B);
    final messageColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Icon and X button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: closeBtnColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(LucideIcons.x, color: closeIconColor, size: 20),
                    onPressed: () => context.pop(false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: closeBtnColor,
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Message (Scrollable)
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    height: 1.5,
                    color: messageColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {
                  onConfirm?.call();
                  context.pop(true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: isDestructive
                      ? const Color(0xFFDC2626) // Red 600
                      : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(confirmText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
