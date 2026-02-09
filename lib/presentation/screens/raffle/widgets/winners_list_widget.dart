import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/domain/models/raffle/raffle_winner.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/clear_winners_dialog.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/reset_raffle_dialog.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/winner_card_widget.dart';
import 'package:quiz_app/routes/app_router.dart';

class WinnersListWidget extends StatelessWidget {
  final List<RaffleWinner> winners;

  const WinnersListWidget({super.key, required this.winners});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with summary
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              // Crown icon at the top
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.amber[300]!, Colors.orange[400]!],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                AppLocalizations.of(context)!.raffleCompleted,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Subtitle with divider
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: Colors.grey[300]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .winnersSelectedCount(winners.length),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(height: 1, color: Colors.grey[300]),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Winners list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: winners.length,
            itemBuilder: (context, index) {
              final winner = winners[index];
              return WinnerCardWidget(winner: winner, index: index);
            },
          ),
        ),

        // Footer with action buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await showResetRaffleDialog(context);
                    if (confirmed && context.mounted) {
                      context.go(AppRoutes.raffle);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    AppLocalizations.of(context)!.newRaffle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showClearWinnersDialog(context);
                    if (confirmed && context.mounted) {
                      context.go(AppRoutes.raffle);
                    }
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: Text(
                    AppLocalizations.of(context)!.resetWinners,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[400],
                    side: BorderSide(color: Colors.red[200]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
