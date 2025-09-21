import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../domain/models/raffle/raffle_session.dart';

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
    return AlertDialog(
      contentPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trophy icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 48,
              color: Colors.amber,
            ),
          ),

          const SizedBox(height: 24),

          // Winner announcement
          Text(
            AppLocalizations.of(context)!.congratulations,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Winner name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text(
              winnerName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Statistics
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.positionLabel(session.winnersCount + 1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.remainingParticipants(session.activeParticipantsCount - 1),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                ElevatedButton.icon(
                  onPressed: onRepeatRaffle,
                  icon: const Icon(Icons.casino),
                  label: Text(AppLocalizations.of(context)!.continueRaffle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Finish raffle button
              ElevatedButton.icon(
                onPressed: onFinishRaffle,
                icon: const Icon(Icons.emoji_events),
                label: Text(
                  session.activeParticipantsCount > 1
                      ? AppLocalizations.of(context)!.winnersTitle
                      : AppLocalizations.of(context)!.finishRaffle,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
