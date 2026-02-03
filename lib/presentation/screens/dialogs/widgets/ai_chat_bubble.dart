import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../../../../core/l10n/app_localizations.dart';

/// A widget that displays a single chat message bubble.
///
/// Renders messages differently based on whether they are from the [isUser]
/// or the AI. AI messages support Markdown rendering via [GptMarkdown].
class AiChatBubble extends StatelessWidget {
  /// The text content to display.
  final String content;

  /// Whether the message is from the user (right-aligned) or AI (left-aligned).
  final bool isUser;

  /// If `true`, styles the bubble to indicate an error state.
  final bool isError;

  /// The name of the AI service (e.g., "OpenAI", "Gemini") to display
  /// above the message for AI responses.
  final String? aiServiceName;

  /// Callback invoked when the retry button is pressed (only shown on error).
  final VoidCallback? onRetry;

  /// Creates a [AiChatBubble].
  const AiChatBubble({
    super.key,
    required this.content,
    required this.isUser,
    this.isError = false,
    this.aiServiceName,
    this.onRetry,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
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
                      Flexible(
                        child: Text(
                          aiServiceName ?? 'AI',
                          style: TextStyle(
                            color: isError
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                      color: isError
                          ? theme.colorScheme.onErrorContainer
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            if (isError && onRetry != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: localizations.retry,
                color: theme.colorScheme.error,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
