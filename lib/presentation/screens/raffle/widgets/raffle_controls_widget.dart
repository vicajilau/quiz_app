import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/raffle_bloc/raffle_bloc.dart';
import '../../../blocs/raffle_bloc/raffle_event.dart';
import '../../../blocs/raffle_bloc/raffle_state.dart';
import '../../../../domain/models/raffle/raffle_session.dart';
import 'raffle_animation_widget.dart';

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
                  isSelecting ? 'Sorteando...' : 'Iniciar Sorteo',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canStartRaffle ? Colors.green : null,
                  foregroundColor: canStartRaffle ? Colors.white : null,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status text
            if (session != null) ...[
              Text(
                _getStatusText(session, isSelecting),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],

            // Additional controls
            if (session != null && session.hasWinners) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showClearWinnersDialog(context),
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reiniciar Ganadores'),
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

  String _getStatusText(RaffleSession session, bool isSelecting) {
    if (isSelecting) {
      return 'Seleccionando ganador...';
    }

    if (session.activeParticipants.isEmpty) {
      if (session.hasParticipants) {
        return 'Todos los participantes ya fueron seleccionados';
      } else {
        return 'Agrega participantes para comenzar el sorteo';
      }
    }

    return '${session.activeParticipantsCount} participante(s) listo(s) para el sorteo';
  }

  void _showClearWinnersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reiniciar Ganadores'),
        content: const Text(
          '¿Estás seguro de que quieres reiniciar la lista de ganadores? '
          'Todos los participantes volverán a estar disponibles para el sorteo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<RaffleBloc>().add(ClearWinners());
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }
}
