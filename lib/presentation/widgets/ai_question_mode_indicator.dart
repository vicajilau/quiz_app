import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../screens/dialogs/ai_generate_questions_dialog.dart';

class AiQuestionModeIndicator extends StatelessWidget {
  final AIQuestionMode mode;
  final int wordCount;

  const AiQuestionModeIndicator({
    super.key,
    required this.mode,
    required this.wordCount,
  });

  String _getPrecisionLevel(AppLocalizations localizations) {
    if (wordCount < 20) return localizations.aiPrecisionLow;
    if (wordCount < 50) return localizations.aiPrecisionMedium;
    return localizations.aiPrecisionHigh;
  }

  double _getPrecisionProgress() {
    if (wordCount < 10) return 0.0;
    if (wordCount < 20) return 0.33;
    if (wordCount < 50) return 0.66;
    return 1.0;
  }

  Color _getPrecisionColor() {
    if (wordCount < 20) return Colors.red;
    if (wordCount < 50) return Colors.amber.shade700;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final Color indicatorColor;
    final IconData indicatorIcon;
    final String title;
    final String description;

    switch (mode) {
      case AIQuestionMode.file:
        indicatorColor = Colors.deepPurple;
        indicatorIcon = Icons.attach_file;
        title = localizations.aiFileMode;
        description = localizations.aiFileModeDescription;
      case AIQuestionMode.topic:
        indicatorColor = Theme.of(context).colorScheme.secondary;
        indicatorIcon = Icons.lightbulb_outline;
        title = localizations.aiModeTopicTitle;
        description = localizations.aiModeTopicDescription;
      case AIQuestionMode.content:
        indicatorColor = _getPrecisionColor();
        indicatorIcon = Icons.article_outlined;
        title = localizations.aiModeContentTitle;
        description = localizations.aiModeContentDescription;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: indicatorColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(indicatorIcon, size: 18, color: indicatorColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: indicatorColor,
                                ),
                          ),
                        ),
                        if (mode != AIQuestionMode.file) ...[
                          const SizedBox(width: 8),
                          Text(
                            localizations.aiWordCountIndicator(wordCount),
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (mode == AIQuestionMode.content) ...[
            const SizedBox(width: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    localizations.aiPrecisionIndicator(
                      _getPrecisionLevel(localizations),
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: indicatorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 60,
                    child: LinearProgressIndicator(
                      value: _getPrecisionProgress(),
                      backgroundColor: indicatorColor.withValues(alpha: 0.2),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(indicatorColor),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
