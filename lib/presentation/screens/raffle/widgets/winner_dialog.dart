import 'package:flutter/material.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/domain/models/raffle/raffle_session.dart';
import 'package:quiz_app/core/theme/app_theme.dart';
import 'package:quiz_app/core/theme/extensions/confirm_dialog_colors_extension.dart';

class WinnerDialog extends StatelessWidget {
  final String winnerName;
  final RaffleSession session;
  final VoidCallback onRepeatRaffle;
  final VoidCallback onFinishRaffle;

  const WinnerDialog({
    super.key,
    required this.winnerName,
    required this.session,
    required this.onRepeatRaffle,
    required this.onFinishRaffle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;

    // Design Tokens
    final titleColor = isDark ? AppTheme.backgroundColor : Colors.black;
    final trophyBg = isDark ? AppTheme.violet900 : AppTheme.violet100;
    final trophyIcon = isDark ? AppTheme.violet400 : AppTheme.primaryColor;
    final nameBg = isDark ? AppTheme.zinc700 : AppTheme.zinc100;
    final nameText = isDark ? AppTheme.backgroundColor : AppTheme.zinc900;
    final statsBg = isDark ? AppTheme.zinc900 : AppTheme.zinc50;
    final statsLabel = isDark ? AppTheme.backgroundColor : Colors.black;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trophy icon
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: trophyBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emoji_events, size: 48, color: trophyIcon),
              ),
            ),

            const SizedBox(height: 24),

            // Winner announcement
            Text(
              AppLocalizations.of(context)!.congratulations,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Winner name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: nameBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                winnerName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: nameText,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Statistics
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statsBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.positionLabel(session.winnersCount + 1),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: statsLabel,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.remainingParticipants(
                      session.activeParticipantsCount - 1,
                    ),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: colors.subtitle,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Continue raffle button
                if (session.activeParticipantsCount > 1) ...[
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: onRepeatRaffle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.casino, size: 20),
                      label: Text(
                        AppLocalizations.of(context)!.continueRaffle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Finish raffle / View Winners button
                SizedBox(
                  height: 56,
                  child: session.activeParticipantsCount > 1
                      ? OutlinedButton.icon(
                          onPressed: onFinishRaffle,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.subtitle,
                            side: BorderSide(
                              color: isDark
                                  ? AppTheme.zinc700
                                  : AppTheme.zinc200,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            Icons.emoji_events,
                            size: 20,
                            color: colors.subtitle,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.winnersTitle,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: onFinishRaffle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.emoji_events, size: 20),
                          label: Text(
                            AppLocalizations.of(context)!.finishRaffle,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
