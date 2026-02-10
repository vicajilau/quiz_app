import 'package:flutter/material.dart';
import 'package:quiz_app/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_bloc.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_event.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_state.dart';
import 'package:quiz_app/domain/models/raffle/raffle_session.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/raffle_animation_widget.dart';
import 'package:quiz_app/presentation/screens/raffle/widgets/clear_winners_dialog.dart';

class RaffleControlsWidget extends StatelessWidget {
  const RaffleControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RaffleBloc, RaffleState>(
      builder: (context, state) {
        RaffleSession? session;
        bool isSelecting = false;

        if (state is RaffleLoaded) {
          session = state.session;
        } else if (state is RaffleWinnerSelected) {
          session = state.session;
        } else if (state is RaffleSelecting) {
          session = state.session;
          isSelecting = true;
        }

        final canStartRaffle =
            session != null && session.canSelectWinner && !isSelecting;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Animation area
            if (isSelecting) ...[
              const RaffleAnimationWidget(),
              const SizedBox(height: 24),
            ],

            // Start Raffle Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: canStartRaffle
                    ? () => _startRaffle(context, session!)
                    : null,
                icon: isSelecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.casino),
                label: Text(
                  isSelecting
                      ? AppLocalizations.of(context)!.raffling
                      : AppLocalizations.of(context)!.startRaffle,
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canStartRaffle
                      ? AppTheme.primaryColor
                      : null,
                  foregroundColor: canStartRaffle ? Colors.white : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status text
            if (session != null) ...[
              Text(
                _getStatusText(session, isSelecting, context),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.zinc500),
              ),
            ],

            // Additional controls
            if (session != null && session.hasWinners) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => showClearWinnersDialog(context),
                        icon: const Icon(Icons.restart_alt),
                        label: Text(
                          AppLocalizations.of(context)!.resetWinners,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: BorderSide(
                            color: AppTheme.errorColor.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  void _startRaffle(BuildContext context, RaffleSession session) {
    final raffleBloc = context.read<RaffleBloc>();

    // Start the selection animation
    raffleBloc.add(StartRaffleSelection());

    // Simulate animation duration and then select winner
    Future.delayed(const Duration(seconds: 3), () {
      final winner = raffleBloc.selectRandomWinner(session.activeParticipants);
      raffleBloc.add(CompleteRaffleSelection(winner));
    });
  }

  String _getStatusText(
    RaffleSession session,
    bool isSelecting,
    BuildContext context,
  ) {
    if (isSelecting) {
      return AppLocalizations.of(context)!.selectingWinner;
    }

    if (session.activeParticipants.isEmpty) {
      if (session.hasParticipants) {
        return AppLocalizations.of(context)!.allParticipantsSelected;
      } else {
        return AppLocalizations.of(context)!.addParticipantsToStart;
      }
    }

    return AppLocalizations.of(
      context,
    )!.participantsReadyCount(session.activeParticipantsCount);
  }
}
