import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../../../../core/l10n/app_localizations.dart';

class AiChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final bool isError;
  final String? aiServiceName;

  const AiChatBubble({
    super.key,
    required this.content,
    required this.isUser,
    this.isError = false,
    this.aiServiceName,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 48),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isError
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(12),
          ),
          border: isError
              ? Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.5),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  aiServiceName?.contains('OpenAI') == true
                      ? Icons.auto_awesome
                      : Icons.auto_fix_high,
                  size: 14,
                  color: isError
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  aiServiceName ?? 'AI',
                  style: TextStyle(
                    color: isError
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.aiAssistant,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isError
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GptMarkdown(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isError ? theme.colorScheme.onErrorContainer : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
