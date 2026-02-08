import 'package:flutter/material.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/domain/models/raffle/raffle_session.dart';

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

    // Design Tokens
    final dialogBg = isDark ? const Color(0xFF27272A) : const Color(0xFFFFFFFF);
    final titleColor = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);
    final contentColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);
    final trophyBg = isDark ? const Color(0xFF4C1D95) : const Color(0xFFEDE9FE);
    final trophyIcon = isDark
        ? const Color(0xFFA78BFA)
        : const Color(0xFF8B5CF6);
    final nameBg = isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5);
    final nameText = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF18181B);
    final statsBg = isDark ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
    final statsLabel = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: dialogBg,
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
                      color: contentColor,
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
                        backgroundColor: const Color(0xFF8B5CF6),
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
                            foregroundColor: contentColor,
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF3F3F46)
                                  : const Color(0xFFE4E4E7),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            Icons.emoji_events,
                            size: 20,
                            color: contentColor,
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
                            backgroundColor: const Color(0xFF8B5CF6),
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
