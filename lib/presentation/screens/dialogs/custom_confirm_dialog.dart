import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// A custom confirmation dialog that matches the app's design language.
///
/// This dialog displays a [title], a [message], and a confirmation button.
/// The dialog can be configured as [isDestructive] to show red accents.
class CustomConfirmDialog extends StatelessWidget {
  /// The title of the dialog.
  final String title;

  /// The message body of the dialog.
  final String message;

  /// The text to display on the confirmation button.
  final String confirmText;

  /// The callback to execute when the confirmation button is pressed.
  ///
  /// If null, the dialog just closes returning `true`.
  final VoidCallback? onConfirm;

  /// Whether the action is destructive (e.g., delete).
  ///
  /// If true, the button and accents will be red.
  final bool isDestructive;

  /// Whether to show the close (X) button in the top right.
  final bool showCloseButton;

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.onConfirm,
    this.isDestructive = false,
    this.showCloseButton = true,
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
        constraints: const BoxConstraints(maxWidth: 520),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: backgroundColor,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Icon and X button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ),
                if (showCloseButton)
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      color: closeBtnColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        LucideIcons.x,
                        color: closeIconColor,
                        size: 20,
                      ),
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
            const SizedBox(height: 32),

            // Actions
            SizedBox(
              width: double.infinity,
              height: 56,
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
